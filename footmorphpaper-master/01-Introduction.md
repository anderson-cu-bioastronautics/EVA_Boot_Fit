---

---

# Introduction {#sec:intro}

Foot shape is known to be highly variable throughout the population, including by sex [@Wunderlich2001; @Krauss2008; @Krauss2010], age [@Tomassoni2014], and weight [@Price2016]. 
This variability is often not captured in footwear sizing, as current footwear fitting standards only use foot length, foot width, and arch length to fit to standardized shoe sizes [@ASTM2017].
Furthermore, footwear is commonly designed around lasts, shoe molds that are sized and shaped by each manufacturer with no common standard, leading to variability in footwear shapes and sizes [@Jurca2013; @Wannop2019]. 
Such variability can make it hard for consumers to find a proper fit, resulting in users having to wear ill-fitting footwear with suboptimal comfort [@Dobson2018b]. 
Footwear comfort has shown benefits in increasing running performance [@Luo2009] and reducing the risk of movement-related injury [@Mundermann2001a], and is often the number one [@Martinez-Martinez2017] factor for consumers to select footwear. 
Footwear should therefore be properly fit to a wide population range in order to be successful. 

However, because the current methodology of designing footwear relies on using static lasts, this assumes that the foot consists of rigid segments.
This fails to account for dynamic changes in foot morphology, especially when the foot is being loaded during gait. 
Assumptions of rigid foot segments during foot loading have shown inaccuracies in estimation of ankle joint mechanics [@Zelik2018; @Kessler2020], suggesting intra-foot motion as the foot is loaded [@Lundgren2008; @Wolf2008]. 
Evidence suggests that foot loading affects linear foot measurements, such as when transitioning from sitting to standing [@Xiong2009; @Oladipo2008] or during the stance phase of gait [@Kouchi2009; @Barisch-Fritz2014; @Grau2018].
The dynamically changing measurements suggest morphological changes occurring, all of which may not be captured in static linear and circumferential measurements. 
Thus, it becomes difficult to characterize the wide variety of foot shapes across not only a large population, but within individuals as their foot goes through loading scenarios such as gait. 

Statistical shape models (SSMs) can explain morphological differences across populations by identifying shape modes which account for variance from the mean foot,. 
These have been developed for whole-body digital human modeling applications to study population and individual variance in body shape [@Allen2003; @Anguelov2005; @Reed2014; @Park2015a; @Park2017]. 
Parametric SSMs are extensions which use correlations between subject anthropometric data and SSM deformations to help predict body shape for new individuals in the population [@Park2015a; @Park2017]. 

SSMs have recently been applied to characterize static foot shape across a population [@Conrad2019] and recognize foot-shape deviations [@Stankovic2020].
The aforementioned efforts to capture foot measurement changes over the gait cycle did capture 4D foot images [@Barisch-Fritz2014;@Grau2018], but these efforts were not translated into a SSM. 
All the previously developed systems were also based on a catwalk, requiring subjects to correctly hit the scanning area for a successful data capture, which may not be representative of natural cadence. 

The development of the DynaMo software [@Boppana2019] for the Intel RealSense D415 Depth Cameras (Intel, Santa Clara CA) allowed a 4D scanning system to be set around a treadmill, where subjects can maintain a natural cadence. 
This system captures the majority of the foot's dorsal surface, but does not allow for the capture of the foot's plantar surface. 
4D scans are captured at 90 fps, enabling a detailed evaluation of foot morphology changes during loading and unloading. 
This study outlines the development of a parametric SSM, derived from scans captured with this system. 
The parametric SSM can characterize and predict dynamic foot morphology at specific points during stance phase across the subject population. 
We hypothesize that there will be significant changes in foot morphology across the dorsal surface of the foot throughout the gait cycle. 
We also hypothesize that these changes will be predictable from the subject demographics of our population. 














