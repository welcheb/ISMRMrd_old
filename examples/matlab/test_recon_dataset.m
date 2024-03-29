%% Working with an existing ISMRMRD data set

% This is a simple example of how to reconstruct images from data
% acquired on a fully sampled cartesian grid
%
% Capabilities:
%   2D/3D
%   multiple slices/slabs
%   multiple contrasts, repetitions
%   
% Limitations:
%   only works with a single encoded space
%   fully sampled k-space (no partial fourier or undersampling)
%   doesn't handle averages, phases, segments and sets
%   ignores noise scans (no pre-whitening)
% 

% We first create a data set using the example program like this:
%   ismrmrd_generate_cartesian_shepp_logan -r 5 -C -o shepp-logan.h5
% This will produce the file shepp-logan.h5 containing an ISMRMRD
% dataset sampled evenly on the k-space grid -128:0.5:127.5 x -128:127
% (i.e. oversampled by a factor of 2 in the readout direction)
% with 8 coils, 5 repetitions and a noise level of 0.5
% with a noise calibration scan at the beginning
%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Loading an existing file %
%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
filename = 'shepp-logan.h5';
if exist(filename, 'file')
    dset = ismrmrd.IsmrmrdDataset(filename, 'dataset');
else
    error(['File ' filename ' does not exist.  Please generate it.'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Read some fields from the XML header %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We need to check if optional fields exists before trying to read them
% Some functions return java.lang.Integer type and we convert to double

%% Encoding and reconstruction information
% Matrix size
enc_Nx = dset.xmlhdr.getEncoding.get(0).getEncodedSpace.getMatrixSize.getX;
enc_Ny = dset.xmlhdr.getEncoding.get(0).getEncodedSpace.getMatrixSize.getY;
enc_Nz = dset.xmlhdr.getEncoding.get(0).getEncodedSpace.getMatrixSize.getZ;
rec_Nx = dset.xmlhdr.getEncoding.get(0).getReconSpace.getMatrixSize.getX;
rec_Ny = dset.xmlhdr.getEncoding.get(0).getReconSpace.getMatrixSize.getY;
rec_Nz = dset.xmlhdr.getEncoding.get(0).getReconSpace.getMatrixSize.getZ;

% Field of View
enc_FOVx = dset.xmlhdr.getEncoding.get(0).getEncodedSpace.getFieldOfViewMm.getX;
enc_FOVy = dset.xmlhdr.getEncoding.get(0).getEncodedSpace.getFieldOfViewMm.getY;
enc_FOVz = dset.xmlhdr.getEncoding.get(0).getEncodedSpace.getFieldOfViewMm.getZ;
rec_FOVx = dset.xmlhdr.getEncoding.get(0).getReconSpace.getFieldOfViewMm.getX;
rec_FOVy = dset.xmlhdr.getEncoding.get(0).getReconSpace.getFieldOfViewMm.getY;
rec_FOVz = dset.xmlhdr.getEncoding.get(0).getReconSpace.getFieldOfViewMm.getZ;

% Number of slices
if isempty(dset.xmlhdr.getEncoding.get(0).getEncodingLimits.getSlice)
    nSlices = 1;
else
    nSlices = dset.xmlhdr.getEncoding.get(0).getEncodingLimits.getSlice.getMaximum;
end

% Number of coils, in the system information
nCoils = double(dset.xmlhdr.getAcquisitionSystemInformation.getReceiverChannels);

% Repetitions, contrasts etc.
if isempty(dset.xmlhdr.getEncoding.get(0).getEncodingLimits.getRepetition)
    nReps = 1;
else
    nReps = double(dset.xmlhdr.getEncoding.get(0).getEncodingLimits.getRepetition.getMaximum);
end

if isempty(dset.xmlhdr.getEncoding.get(0).getEncodingLimits.getContrast)
    nContrasts = 1;
else
    nContrasts = double(dset.xmlhdr.getEncoding.get(0).getEncodingLimits.getContrast.getMaximum);
end

% TODO add the other possibilites

%% Read all the data
% Reading can be done one acquisition (or chunk) at a time, 
% but this is much faster for data sets that fit into RAM.
D = dset.readAcquisition();

% Note: can select a single acquisition or header from the block, e.g.
% acq = D.select(5);
% hdr = D.head.select(5);
% or you can work with them all together

%% Ignore noise scans
% TODO add a pre-whitening example
% Find the first non-noise scan
% This is how to check if a flag is set in the acquisition header
isNoise = D.head.flagIsSet(D.head.FLAGS.ACQ_IS_NOISE_MEASUREMENT);
firstScan = find(isNoise==0,1,'first');
if firstScan > 1
    noise = D.select(1:firstScan-1);
else
    noise = [];
end
meas  = D.select(firstScan:D.getNumber);
clear D;

%% Reconstruct images
% Since the entire file is in memory we can use random access
% Loop over repetitions, contrasts, slices
reconImages = {};
nimages = 0;
for rep = 1:nReps
    for contrast = 1:nContrasts
        for slice = 1:nSlices
            % Initialize the K-space storage array
            K = zeros(enc_Nx, enc_Ny, enc_Nz, nCoils);
            % Select the appropriate measurements from the data
            acqs = find(  (meas.head.idx.contrast==(contrast-1)) ...
                        & (meas.head.idx.repetition==(rep-1)) ...
                        & (meas.head.idx.slice==(slice-1)));
            for p = 1:length(acqs)
                ky = meas.head.idx.kspace_encode_step_1(acqs(p)) + 1;
                kz = meas.head.idx.kspace_encode_step_2(acqs(p)) + 1;
                K(:,ky,kz,:) = meas.data{acqs(p)};
            end
            % Reconstruct in x
            K = fftshift(ifft(fftshift(K,1),[],1),1);
            % Chop if needed
            if (enc_Nx == rec_Nx)
                im = K;
            else
                ind1 = floor((enc_Nx - rec_Nx)/2)+1;
                ind2 = floor((enc_Nx - rec_Nx)/2)+rec_Nx;
                im = K(ind1:ind2,:,:,:);
            end
            % Reconstruct in y then z
            im = fftshift(ifft(fftshift(im,2),[],2),2);
            if size(im,3)>1
                im = fftshift(ifft(fftshift(im,3),[],3),3);
            end
            
            % Combine SOS across coils
            im = sqrt(sum(abs(im).^2,4));
            
            % Append
            nimages = nimages + 1;
            reconImages{nimages} = im;
        end
    end
end

%% Display the first image
figure
colormap gray
imagesc(reconImages{1}); axis image; axis off; colorbar;
