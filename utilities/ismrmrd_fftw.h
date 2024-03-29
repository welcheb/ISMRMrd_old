/*
 * ismrmrd_fftw.h
 *
 *  Created on: Apr 1, 2013
 *      Author: Michael S. Hansen
 */

#include "fftw3.h"

namespace ISMRMRD {

template<typename TI, typename TO> void circshift(TO *out, const TI *in, int xdim, int ydim, int xshift, int yshift)
{
  for (int i =0; i < ydim; i++) {
    int ii = (i + yshift) % ydim;
    for (int j = 0; j < xdim; j++) {
      int jj = (j + xshift) % xdim;
      out[ii * xdim + jj] = in[i * xdim + j];
    }
  }
}

#define fftshift(out, in, x, y) circshift(out, in, x, y, (x/2), (y/2))


int fft2c(NDArrayContainer<std::complex<float> >& a, bool forward)
{
	if (a.dimensions_.size() < 2) {
		std::cout << "fft2c Error: input array must have at least two dimensions" << std::endl;
		return -1;
	}

	size_t elements =  a.dimensions_[0]*a.dimensions_[1];
	size_t ffts = a.data_.size()/elements;

	//Array for transformation
	fftwf_complex* tmp = (fftwf_complex*)fftwf_malloc(sizeof(fftwf_complex)*a.data_.size());

	if (!tmp) {
		std::cout << "Error allocating temporary storage for FFTW" << std::endl;
		return -1;
	}


	for (size_t f = 0; f < ffts; f++) {
		size_t index = f*elements;
		fftshift(reinterpret_cast<std::complex<float>*>(tmp),&a.data_[index],a.dimensions_[0],a.dimensions_[1]);

		//Create the FFTW plan
		fftwf_plan p;
		if (forward) {
			p = fftwf_plan_dft_2d(a.dimensions_[1], a.dimensions_[0], tmp,tmp, FFTW_FORWARD, FFTW_ESTIMATE);
		} else {
			p = fftwf_plan_dft_2d(a.dimensions_[1], a.dimensions_[0], tmp,tmp, FFTW_BACKWARD, FFTW_ESTIMATE);
		}
		fftwf_execute(p);

		fftshift(&a.data_[index],reinterpret_cast<std::complex<float>*>(tmp),a.dimensions_[0],a.dimensions_[1]);

		//Clean up.
		fftwf_destroy_plan(p);
	}

	std::complex<float> scale(std::sqrt(1.0f*elements),0.0);
	a.data_ /= scale;

	fftwf_free(tmp);
	return 0;
}

int fft2c(NDArrayContainer<std::complex<float> >& a) {
	return fft2c(a,true);
}

int ifft2c(NDArrayContainer<std::complex<float> >& a) {
	return fft2c(a,false);
}

};
