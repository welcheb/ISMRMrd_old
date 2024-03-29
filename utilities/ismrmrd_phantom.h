/*
 * ismrmrd_phantom.h
 *
 *  Created on: Apr 1, 2013
 *      Author: Michael S. Hansen
 */

#include <boost/shared_ptr.hpp>
#include <complex>
#include "ismrmrd.h"
#include "ismrmrd_utilities_export.h"

#ifndef ISMRMRD_PHANTOM_H_
#define ISMRMRD_PHANTOM_H_

namespace ISMRMRD {

	class PhantomEllipse
	{
	public:
		PhantomEllipse(float A, float a, float b, float x0, float y0, float phi)
			: A_(A)
			, a_(a)
			, b_(b)
			, x0_(x0)
			, y0_(y0)
			, phi_(phi)
		{

		}

		bool isInside(float x, float y)
		{
			float asq = a_*a_;                // a^2
			float bsq = b_*b_;                // b^2
			float phi = phi_*3.14159265359/180; // rotation angle in radians
			float x0  = x-x0_; 					  // x offset
			float y0 =  y-y0_;                     // y offset
			float cosp = cos(phi);
			float sinp = sin(phi);
			return (((x0*cosp + y0*sinp)*(x0*cosp + y0*sinp))/asq + ((y0*cosp - x0*sinp)*(y0*cosp - x0*sinp))/bsq <= 1);
		}

		float getAmplitude()
		{
			return A_;
		}


	protected:

		float A_;
		float a_;
		float b_;
		float x0_;
		float y0_;
		float phi_;
	};

	EXPORTISMRMRDUTILITIES boost::shared_ptr< std::vector<PhantomEllipse> > shepp_logan_ellipses();
	EXPORTISMRMRDUTILITIES boost::shared_ptr< std::vector<PhantomEllipse> > modified_shepp_logan_ellipses();

	EXPORTISMRMRDUTILITIES boost::shared_ptr<NDArrayContainer< std::complex<float> > > phantom(NDArrayContainer<float>& coefficients, unsigned int matrix_size);
	EXPORTISMRMRDUTILITIES boost::shared_ptr<NDArrayContainer< std::complex<float> > > shepp_logan_phantom(unsigned int matrix_size);

	EXPORTISMRMRDUTILITIES boost::shared_ptr<NDArrayContainer< std::complex<float> > > generate_birdcage_sensititivies(unsigned int matrix_size, unsigned int ncoils, float relative_radius);

	EXPORTISMRMRDUTILITIES int add_noise(NDArrayContainer< std::complex<float> >& a, float sd);
	EXPORTISMRMRDUTILITIES int add_noise(ISMRMRD::Acquisition& a, float sd);

};

#endif /* ISMRMRD_PHANTOM_H_ */
