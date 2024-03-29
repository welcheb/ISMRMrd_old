classdef ImageHeader < handle
    
    properties
        
        version = uint16([]);                % First unsigned int indicates the version %
        flags = uint64([]);                  % bit field with flags %
        measurement_uid = uint32([]);        % Unique ID for the measurement %
        matrix_size = uint16([]);            % Pixels in the 3 spatial dimensions
        field_of_view = single([]);          % Size (in mm) of the 3 spatial dimensions %
        channels = uint16([]);               % Number of receive channels %
        position = single([]);               % Three-dimensional spatial offsets from isocenter %
        read_dir = single([]);               % Directional cosines of the readout/frequency encoding %
        phase_dir = single([]);              % Directional cosines of the phase encoding %
        slice_dir = single([]);              % Directional cosines of the slice %
        patient_table_position = single([]); % Patient table off-center %
        average = uint16([]);                % e.g. signal average number %
        slice = uint16([]);                  % e.g. imaging slice number %
        contrast = uint16([]);               % e.g. echo number in multi-echo %
        phase = uint16([]);                  % e.g. cardiac phase number %
        repetition = uint16([]);             % e.g. dynamic number for dynamic scanning %
        set = uint16([]);                    % e.g. flow encodning set %
        acquisition_time_stamp = uint32([]); % Acquisition clock %
        physiology_time_stamp = uint32([]);  % Physiology time stamps, e.g. ecg, breating, etc. %
        image_data_type = uint16([]);        % e.g. unsigned short, float, complex float, etc. %
        image_type = uint16([]);             % e.g. magnitude, phase, complex, real, imag, etc. %
        image_index = uint16([]);			 % e.g. image number in series of images  %
        image_series_index = uint16([]);     % e.g. series number %
        user_int = int32([]);                % Free user parameters %
        user_float = single([]);             % Free user parameters %
        
    end

    properties(Constant)
        FLAGS = struct( ...
            'IMAGE_IS_NAVIGATION_DATA', 23, ...
            'IMAGE_USER1',              57, ...
            'IMAGE_USER2',              58, ...
            'IMAGE_USER3',              59, ...
            'IMAGE_USER4',              60, ...
            'IMAGE_USER5',              61, ...
            'IMAGE_USER6',              62, ...
            'IMAGE_USER7',              63, ...
            'IMAGE_USER8',              64);
        
        DATA_TYPE = struct( ...
            'FLOAT',          uint16(1), ...
            'DOUBLE',         uint16(2), ...
            'COMPLEX_FLOAT',  uint16(3), ...
            'COMPLEX_DOUBLE', uint16(4), ...
            'UNSIGNED_SHORT', uint16(5));
        
        IMAGE_TYPE = struct( ...
            'TYPE_MAGNITUDE', uint16(1), ...
            'TYPE_PHASE',     uint16(2), ...
            'TYPE_REAL',      uint16(3), ...
            'TYPE_IMAG',      uint16(4), ...
            'TYPE_COMPLEX',   uint16(5));

    end
    
    methods
        
        function obj = ImageHeader(arg)
            switch nargin
                case 0
                    % No argument constructor
                    % initialize to a single image header
                    extend(obj,1);
                    
                case 1
                    % One argument constructor
                    if isstruct(arg)
                        % plain struct
                        fromStruct(obj,arg);
                    elseif (length(arg)==1 && ismrmrd.util.isInt(arg)) == 1
                        % number
                        extend(obj,arg);
                    elseif isa(arg,'int8')
                        % Byte array
                        fromBytes(obj,arg);
                    else
                        % Unknown type
                        error('Unknown argument type.')
                    end
                    
                otherwise
                    error('Wrong number of arguments.')
                    
            end
        end
        
        function nacq = getNumber(obj)
            nacq = length(obj.version);
        end
        
        function hdr = select(obj, range)
            % Return a copy of a range of image headers
            
            % create an empty image header
            M = length(range);
            hdr = ismrmrd.ImageHeader(M);
            
            % Fill
            hdr.version = obj.version(range);
            hdr.flags = obj.flags(range);
            hdr.measurement_uid = obj.measurement_uid(range);
            hdr.matrix_size = obj.matrix_size(:,range);
            hdr.field_of_view = obj.field_of_view(:,range);
            hdr.channels = obj.channels(:,range);
            hdr.position = obj.position(:,range);
            hdr.read_dir = obj.read_dir(:,range);
            hdr.phase_dir = obj.phase_dir(:,range);
            hdr.slice_dir = obj.slice_dir(:,range);
            hdr.patient_table_position = obj.patient_table_position(:,range);
            hdr.average = obj.average(range);
            hdr.slice = obj.slice(range);
            hdr.contrast = obj.contrast(range);
            hdr.phase = obj.phase(range);
            hdr.repetition = obj.repetition(range);
            hdr.set = obj.set(range);
            hdr.acquisition_time_stamp = obj.acquisition_time_stamp(range);
            hdr.physiology_time_stamp = obj.physiology_time_stamp(:,range);
            hdr.image_data_type = obj.image_data_type(range);
            hdr.image_type = obj.image_type(range);
            hdr.image_index = obj.image_index(range);
            hdr.image_series_index = obj.image_series_index(range);
            hdr.user_int = obj.user_int(:,range);
            hdr.user_float = obj.user_float(:,range);

        end        
        
        function extend(obj,N)
            % Extend with blank header

            range = obj.getNumber + (1:N);            
            obj.version(1,range)                  = zeros(1,N,'uint16');
            obj.flags(1,range)                    = zeros(1,N,'uint64');
            obj.measurement_uid(1,range)          = zeros(1,N,'uint32');
            obj.matrix_size(1:3,range)            = zeros(3,N,'uint16');
            obj.field_of_view(1:3,range)          = zeros(3,N,'single');
            obj.channels(1,range)                 = zeros(1,N,'uint16');
            obj.position(1:3,range)               = zeros(3,N,'single');
            obj.read_dir(1:3,range)               = zeros(3,N,'single');
            obj.phase_dir(1:3,range)              = zeros(3,N,'single');
            obj.slice_dir(1:3,range)              = zeros(3,N,'single');
            obj.patient_table_position(1:3,range) = zeros(3,N,'single');
            obj.average(1,range)                  = zeros(1,N,'uint16');
            obj.slice(1,range)                    = zeros(1,N,'uint16');
            obj.contrast(1,range)                 = zeros(1,N,'uint16');
            obj.phase(1,range)                    = zeros(1,N,'uint16');
            obj.repetition(1,range)               = zeros(1,N,'uint16');
            obj.set(1,range)                      = zeros(1,N,'uint16');
            obj.acquisition_time_stamp(1,range)   = zeros(1,N,'uint32');
            obj.physiology_time_stamp(1:3,range)  = zeros(3,N,'uint32');
            obj.image_data_type(1,range)          = zeros(1,N,'uint16');
            obj.image_type(1,range)               = zeros(1,N,'uint16');
            obj.image_index(1,range)              = zeros(1,N,'uint16');
            obj.image_series_index(1,range)       = zeros(1,N,'uint16');
            obj.user_int(1:8,range)               = zeros(8,N,'int32');
            obj.user_float(1:8,range)             = zeros(8,N,'single');
        end
        
        function append(obj, head)
            Nstart = obj.getNumber + 1;
            Nend   = obj.getNumber + length(head.version);
            Nrange = Nstart:Nend;
            obj.version(Nrange) = hdr.version;
            obj.flags(Nrange) = hdr.flags;
            obj.measurement_uid(Nrange) = hdr.measurement_uid;
            obj.matrix_size(:,Nrange) = hdr.matrix_size;
            obj.field_of_view(:,Nrange) = hdr.field_of_view;
            obj.channels(Nrange) = hdr.channels;
            obj.position(:,Nrange) = hdr.position;
            obj.read_dir(:,Nrange) = hdr.read_dir;
            obj.phase_dir(:,Nrange) = hdr.phase_dir;
            obj.slice_dir(:,Nrange) = hdr.slice_dir;
            obj.patient_table_position(:,Nrange) = hdr.patient_table_position;
            obj.average(Nrange) = hdr.average;
            obj.slice(Nrange) = hdr.slice;
            obj.contrast(Nrange) = hdr.contrast;
            obj.phase(Nrange) = hdr.phase;
            obj.repetition(Nrange) = hdr.repetition;
            obj.set(Nrange) = hdr.set;
            obj.acquisition_time_stamp(Nrange) = hdr.acquisition_time_stamp;
            obj.physiology_time_stamp(:,Nrange) = hdr.physiology_time_stamp;
            obj.image_data_type(Nrange) = hdr.image_data_type;
            obj.image_type(Nrange) = hdr.image_type;
            obj.image_index(Nrange) = hdr.image_index;
            obj.image_series_index(Nrange) = hdr.image_series_index;
            obj.user_int(:,Nrange) = hdr.user_int;
            obj.user_float(:,Nrange) = hdr.user_float;            
            
        end

        function fromStruct(obj, hdr)
            %warning! no error checking
            obj.version = hdr.version;
            obj.flags = hdr.flags;
            obj.measurement_uid = hdr.measurement_uid;
            obj.matrix_size = hdr.matrix_size;
            obj.field_of_view = hdr.field_of_view;
            obj.channels = hdr.channels;
            obj.position = hdr.position;
            obj.read_dir = hdr.read_dir;
            obj.phase_dir = hdr.phase_dir;
            obj.slice_dir = hdr.slice_dir;
            obj.patient_table_position = hdr.patient_table_position;
            obj.average = hdr.average;
            obj.slice = hdr.slice;
            obj.contrast = hdr.contrast;
            obj.phase = hdr.phase;
            obj.repetition = hdr.repetition;
            obj.set = hdr.set;
            obj.acquisition_time_stamp = hdr.acquisition_time_stamp;
            obj.physiology_time_stamp = hdr.physiology_time_stamp;
            obj.image_data_type = hdr.image_data_type;
            obj.image_type = hdr.image_type;
            obj.image_index = hdr.image_index;
            obj.image_series_index = hdr.image_series_index;
            obj.user_int = hdr.user_int;
            obj.user_float = hdr.user_float;
        end

        function hdr = toStruct(obj)
            %warning! no error checking
            hdr = struct();
            hdr.version = obj.version;
            hdr.flags = obj.flags;
            hdr.measurement_uid = obj.measurement_uid;
            hdr.matrix_size = obj.matrix_size;
            hdr.field_of_view = obj.field_of_view;
            hdr.channels = obj.channels;
            hdr.position = obj.position;
            hdr.read_dir = obj.read_dir;
            hdr.phase_dir = obj.phase_dir;
            hdr.slice_dir = obj.slice_dir;
            hdr.patient_table_position = obj.patient_table_position;
            hdr.average = obj.average;
            hdr.slice = obj.slice;
            hdr.contrast = obj.contrast;
            hdr.phase = obj.phase;
            hdr.repetition = obj.repetition;
            hdr.set = obj.set;
            hdr.acquisition_time_stamp = obj.acquisition_time_stamp;
            hdr.physiology_time_stamp = obj.physiology_time_stamp;
            hdr.image_data_type = obj.image_data_type;
            hdr.image_type = obj.image_type;
            hdr.image_index = obj.image_index;
            hdr.image_series_index = obj.image_series_index;
            hdr.user_int = obj.user_int;
            hdr.user_float = obj.user_float;            
        end
        
        function fromBytes(obj, bytearray)

            % TODO: physiology_time_stamp should be 3. So size will change
            % from 214 to 194;
            if size(bytearray,1) ~= 214
                error('Wrong number of bytes for AcquisitionHeader.')
            end
            N = size(bytearray,2);
            for p = 1:N
                obj.version(p)                  = typecast(bytes(1:2,p),     'uint16');
                obj.flags(p)                    = typecast(bytes(3:10,p),    'uint64');
                obj.measurement_uid(p)          = typecast(bytes(11:14,p),   'uint32');
                obj.matrix_size(:,p)            = typecast(bytes(15:20,p),   'uint16');
                obj.field_of_view(:,p)          = typecast(bytes(21:32,p),   'single');
                obj.channels(p)                 = typecast(bytes(33:34,p),   'uint16');
                obj.position(:,p)               = typecast(bytes(35:46,p),   'single');
                obj.read_dir(:,p)               = typecast(bytes(47:58,p),   'single');
                obj.phase_dir(:,p)              = typecast(bytes(59:70,p),   'single');
                obj.slice_dir(:,p)              = typecast(bytes(71:82,p),   'single');
                obj.patient_table_position(:,p) = typecast(bytes(83:94,p),   'single');
                obj.average(p)                  = typecast(bytes(95:96,p),   'uint16');
                obj.slice(p)                    = typecast(bytes(97:98,p),   'uint16');
                obj.contrast(p)                 = typecast(bytes(99:100,p),  'uint16');
                obj.phase(p)                    = typecast(bytes(101:102,p), 'uint16');
                obj.repetition(p)               = typecast(bytes(103:104,p), 'uint16');
                obj.set(p)                      = typecast(bytes(105:106,p), 'uint16');
                obj.acquisition_time_stamp(p)   = typecast(bytes(107:110,p), 'uint32');
                obj.physiology_time_stamp(:,p)  = typecast(bytes(111:122,p), 'uint32');
                                    ... %   TODO: the C header has a bug.  3 is correct                
                obj.image_data_type(p)          = typecast(bytes(143:144,p), 'uint16');
                obj.image_type(p)               = typecast(bytes(145:146,p), 'uint16');
                obj.image_index(p)              = typecast(bytes(147:148,p), 'uint16');
                obj.image_series_index(p)       = typecast(bytes(149:150,p), 'uint16');
                obj.user_int(:,p)               = typecast(bytes(151:182,p), 'uint32');
                obj.user_float(:,p)             = typecast(bytes(183:214,p), 'single');
            end              
        end
        
        function bytes = toBytes(obj)
            % Convert to an ISMRMRD AcquisitionHeader struct to a byte array.

            N = obj.getNumber;
            
            % TODO: physiology_time_stamp should be 3.
            %bytes = zeros(194,N,'int8');
            bytes = zeros(214,N,'int8');
            for p = 1:N
                off = 1;
                bytes(off:off+1,p)   = typecast(obj.version(p)                 ,'int8'); off=off+2;
                bytes(off:off+7,p)   = typecast(obj.flags(p)                   ,'int8'); off=off+8;
                bytes(off:off+3,p)   = typecast(obj.measurement_uid(p)         ,'int8'); off=off+4;
                bytes(off:off+5,p)   = typecast(obj.matrix_size(:,p)           ,'int8'); off=off+6;
                bytes(off:off+11,p)  = typecast(obj.field_of_view(:,p)         ,'int8'); off=off+12;
                bytes(off:off+1,p)   = typecast(obj.channels(p)                ,'int8'); off=off+2;
                bytes(off:off+11,p)  = typecast(obj.position(:,p)              ,'int8'); off=off+12;
                bytes(off:off+11,p)  = typecast(obj.read_dir(:,p)              ,'int8'); off=off+12;
                bytes(off:off+11,p)  = typecast(obj.phase_dir(:,p)             ,'int8'); off=off+12;
                bytes(off:off+11,p)  = typecast(obj.slice_dir(:,p)             ,'int8'); off=off+12;
                bytes(off:off+11,p)  = typecast(obj.patient_table_position(:,p),'int8'); off=off+12;
                bytes(off:off+1,p)   = typecast(obj.average(p)                 ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.slice(p)                   ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.contrast(p)                ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.phase(p)                   ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.repetition(p)              ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.set(p)                     ,'int8'); off=off+2;
                bytes(off:off+3,p)   = typecast(obj.acquisition_time_stamp(p)  ,'int8'); off=off+4;
                % TODO: physiology_time_stamp should be 3.
                % but the C struct has a bug, so convert to padding.
                bytes(off:off+11,p)  = typecast(obj.physiology_time_stamp(:,p) ,'int8'); off=off+12;
                off = off+20; % Discard 5*uint32;
                bytes(off:off+1,p)   = typecast(obj.image_data_type(p)         ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.image_type(p)              ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.image_index(p)             ,'int8'); off=off+2;
                bytes(off:off+1,p)   = typecast(obj.image_series_index(p)      ,'int8'); off=off+2;
                bytes(off:off+31,p)  = typecast(obj.user_int(:,p)              ,'int8'); off=off+32;
                bytes(off:off+31,p)  = typecast(obj.user_float(:,p)            ,'int8');
            end
        end
        
        function ret = flagIsSet(obj, flag, range)
            if nargin < 3
                range = 1:obj.getNumber;
            end
            if isa(flag, 'char')
                b = obj.FLAGS.(flag);
            elseif (flag>0)
                b = uint64(flag);
            else
                error('Flag is of the wrong type.'); 
            end
            bitmask = bitshift(uint64(1),(b-1));
            ret = zeros(size(range));
            for p = 1:length(range)
                ret(p) = (bitand(obj.flags(range(p)), bitmask)>0);
            end
        end
        
        function flagSet(obj, flag, range)
            if nargin < 3
                range = 1:obj.getNumber;
            end
            if isa(flag, 'char')
                b = obj.FLAGS.(flag);
            elseif (flag>0)
                b = uint64(flag);
            else
                error('Flag is of the wrong type.'); 
            end
            bitmask = bitshift(uint64(1),(b-1));

            alreadyset = obj.flagIsSet(flag,range);
            for p = 1:length(range)
                if ~alreadyset(p)
                    obj.flags(range(p)) = obj.flags(range(p)) + bitmask;
                end
            end
        end
        
        function flagClear(obj, flag, range)
            if nargin < 3
                range = 1:obj.getNumber;
            end
            
            if isa(flag, 'char')
                b = obj.FLAGS.(flag);
            elseif (flag>0)
                b = uint64(flag);
            else
                error('Flag is of the wrong type.'); 
            end
            bitmask = bitshift(uint64(1),(b-1));
            
            alreadyset = obj.flagIsSet(flag,range);
            for p = 1:length(range)
                if alreadyset(p)
                    obj.flags(range(p)) = obj.flags(range(p)) - bitmask;
                end
            end
                
            
        end
        
    end
    
end
