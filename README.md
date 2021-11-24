# ML_CAFE
Deep learning data-preprocessing and application of CNN.

For more information on model and features, see "ML_Report.doc".


## OctMain.m
carries out the data pre-processing where pressure-only WIA is performed on each patient given their derived central pressure. p-WI waveform is then plotted and saved as standardized png files (through cnn_pre.m). Then data augmentation code is also included in this Octmain.m file. Waveforms are saved in the end, for fully connected DNN attempt.

## CNN.m 
used for Convolutional neural network implementation (Require additional MATLAB toolbox)

## DNN.m 
attempts to create a feedforward backpropagating fully connected network. Which currently fails to work given the training dataset. Proposely adding LSTM unit can potentially help the model to better generalise.



The wave intensity analysis (WIA) is performed based on the code provided by:

# Sphygmocor-reservoir
Reservoir Analysis using a matlab batch process for multiple Sphygmocor© files (bRes_sp)

For background see *Alun Hughes, Kim Parker. The modified arterial reservoir: an update with consideration of asymptotic pressure (P∞) and zero-flow pressure (Pzf). Proceedings of the Institution of Mechanical Engineers, Part H: Journal of Engineering in Medicine in press.* https://doi.org/10.1177/0954411920917557 and Kim Parker's website pages on Reservoir/excess pressure (http://www.bg.ic.ac.uk/research/k.parker/res_press_web/rp_home.html).

I am grateful to my long-term colleague Prof. Kim Parker for his assistance with the development of this program. 

*This MATLAB script replaces a previous version called batch_res. Earlier versions of batch_res and kreservoir (v13) may be available on Kim Parker's web page.* **NB that old versions (batch_res_vXX and kreservoir_v13) are now outdated and the current version (bRes_sp and kreservoir v14) should be used. Henceforth any new versions will be made available here.** 


## The script

bRes_sp is a matlab script that calculates reservoir and excess pressure according to the methods described in Davies et al.[1] for Sphygmocor© derived files. A few minor changes have been made since the original description. An improved algorithm for fitting the reservoir in diastole is now used  -- this excludes upstrokes at the end of diastole from the fit (presumed to be due to the next beat). This results in lower values for P∞ and slightly different values for other reservoir parameters. The program assumes that the first element of the pressure P corresponds to the end diastolic pressure in the arterial pressure waveform; i.e. the time of minimum P just before the rapid rise in P during early systole. 


The root mean square of successive differences (RMSSD), the standard deviation of the pulse intervals (SDNN) and baroreflex sensitivity (BRS) are calculated essentially according to Sluyter et al.[2],<sup>[a]</sup> The validity of such ultrashort recordings has been studied by Munoz et al.[3] Further details on the meaning and interpretation of these measures can be found in Shaffer and Ginsberg.[4] It is probably useful to normalise HRV (or adjust it statistically) to mean RR interval due to the correlation between HRV and resting heart rate.[5] This can be done as a post-processing step in the statistical package used.

## Wave intensity

**[NB THESE MEASURES ARE EXPERIMENTAL FOR SPHYGMOCOR DATA]**

If it is assumed that excess pressure (*Pxs*) is proportional to aortic flow velocity (*U*) (essentially a 3-element Windkessel assumption -- see above) then the pattern of aortic wave intensity (*dI*) can be estimated (being proportional to *dP* x *dPxs*). If one of aortic wave speed or *dU* is known then wave intensity can be estimated. If only pressure has been measured this problem cannot be solved without strong assumptions. In this case, it is assumed that peak aortic flow (*dU)* is 1m/s (based on [6]) and doesn't not vary with age, sex etc. While this is not true, it is may prove an acceptable approximation. Further details including preliminary validation can be found in [7]. 



## References

1. Davies JE, Lacy P, Tillin T, et al. Excess pressure integral predicts cardiovascular events independent of other risk factors in the conduit artery functional evaluation substudy of Anglo-Scandinavian Cardiac Outcomes Trial. *Hypertension* 2014; **64**(1): 60-8.
2. Sluyter JD, Hughes AD, Camargo CA, Jr., Lowe A, Scragg RKR. Relations of Demographic and Clinical Factors With Cardiovascular Autonomic Function in a Population-Based Study: An Assessment By Quantile Regression. *Am J Hypertens* 2017; **31**(1): 53-62.
3. Munoz ML, van Roon A, Riese H, et al. Validity of (Ultra-)Short Recordings for Heart Rate Variability Measurements. *PLoS One* 2015; **10**(9): e0138921.
4. Shaffer F, Ginsberg JP. An Overview of Heart Rate Variability Metrics and Norms. *Front Public Health* 2017; **5**: 258.
5. van Roon AM, Snieder H, Lefrandt JD, de Geus EJ, Riese H. Parsimonious Correction of Heart Rate Variability for Its Dependency on Heart Rate. *Hypertension* 2016; **68**(5): e63-e5.
6. Hughes AD, Park C, Ramakrishnan A, Mayet J, Chaturvedi N and Parker KH. Feasibility of Estimation of Aortic Wave Intensity Using Non-invasive Pressure Recordings in the Absence of Flow Velocity in Man. *Front Physiol* 2020; **11**:550. doi: 10.3389/fphys.2020.00550
7. Hughes AD, Park C, Ramakrishnan A, Mayet J, Chaturvedi N, Parker KH. Feasibility of Estimation of Aortic Wave Intensity Using Non-invasive Pressure Recordings in the Absence of Flow Velocity in Man. Front Physiol 2020; **11**: in press.
8. Westerhof N, Westerhof BE. The reservoir wave paradigm discussion. *J Hypertens* 2015; **33**(3): 458-60.
9. Wang J, Jr., O\'Brien AB, Shrive NG, Parker KH, Tyberg JV. Time-domain representation of ventricular-arterial coupling as a windkessel and wave system. *Am J Physiol Heart Circ Physiol* 2003; **284**(4): H1358\--68.
10. Hametner B, Wassertheurer S, Kropf J, et al. Wave reflection quantification based on pressure waveforms alone\--methods, comparison, and clinical covariates. *Comput Meth Prog Bio* 2013; **109**(3): 250-9.
