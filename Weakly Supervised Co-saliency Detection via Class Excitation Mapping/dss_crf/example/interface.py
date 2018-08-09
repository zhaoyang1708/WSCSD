#!/usr/bin/python

"""
Adapted from the original C++ example: densecrf/examples/dense_inference.cpp
http://www.philkr.net/home/densecrf Version 2.2
"""

import numpy as np
import cv2
import pydensecrf.densecrf as dcrf
from skimage.segmentation import relabel_sequential
import sys

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

EPSILON = 1e-8

def crf(img_name,annos_name,output_name,w1,afa,beta):
	img = cv2.imread(img_name, 1)
	annos = cv2.imread(annos_name, 0) 
	#labels = relabel_sequential(cv2.imread(annos_name, 0))[0].flatten()
	output = output_name

	M = 2  # salient or not
	tau = 1.05
	# Setup the CRF model
	d = dcrf.DenseCRF2D(img.shape[1], img.shape[0], M)

	anno_norm = annos / 255.
	n_energy = -np.log((1.0 - anno_norm + EPSILON)) / (tau * sigmoid(1 - anno_norm))
	p_energy = -np.log(anno_norm + EPSILON) / (tau * sigmoid(anno_norm))

	U = np.zeros((M, img.shape[0] * img.shape[1]), dtype='float32')
	U[0, :] = n_energy.flatten()
	U[1, :] = p_energy.flatten()

	d.setUnaryEnergy(U)

	d.addPairwiseGaussian(sxy=3, compat=3)
	#d.addPairwiseBilateral(sxy=60, srgb=5, rgbim=img, compat=5)
	d.addPairwiseBilateral(sxy=afa, srgb=beta, rgbim=img, compat=w1)
	# Do the inference
	infer = np.array(d.inference(1)).astype('float32')
	res = infer[1,:]

	#res *= 255 / res.max()
	res = res * 255
	res = res.reshape(img.shape[:2])
	cv2.imwrite(output, res.astype('uint8'))


#fn_im = './icoseg_18/people/224265550_a9f5706373.jpg'
#fn_anno = './CEM_DRFI_Smooth_iCoseg/people/224265550_a9f5706373.png'
#fn_output = './CRF_OUT_CEM_DRFI_Smooth_iCoseg/people/224265550_a9f5706373.png'
#crf(fn_im,fn_anno,fn_output)

oDir = './icoseg_18/'
tdmDir = './CEM_DRFI_Smooth_tanh_icoseg/'
for w in range(3,7):
    for afa in range(30,101,10):
        for beta in range(3,7):
            outPutDir = './crf_icoseg/icoseg_' + str(w) + '_' + str(afa) + '_' + str(beta) + '/'
            if not os.path.exists(outPutDir):
            	os.makedirs(outPutDir)
            pathDirs =  os.listdir(tdmDir)
            for classDir in pathDirs:
            	oimgDir = oDir + classDir + '/'
            	timgDir = tdmDir + classDir + '/'
            	timgPaths = os.listdir(timgDir)
            	for img_name in timgPaths:
            		#fn_im = oimgDir + img_name[:-4] + '.jpg'
            		fn_anno = timgDir + img_name
            		print(fn_anno)
            		fn_im = oimgDir + img_name[:-4] + '.jpg'
            		print(fn_im)
            		fn_pro = outPutDir + classDir
            		if not os.path.exists(fn_pro):
            			os.makedirs(fn_pro)
            		fn_output = fn_pro + '/' + img_name[:-4] + '.png'
            		crf(fn_im,fn_anno,fn_output,w,afa,beta)