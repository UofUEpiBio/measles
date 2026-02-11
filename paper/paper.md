---
title: 'measles: Tools for Simulating and Investigating Measles Outbreaks with R'
tags:
  - R
  - epidemiology
  - measles
  - agent-based models
  - public health
authors:
  - given-names: George G
    surname: Vega Yon
    orcid: 0000-0002-3171-0844
    equal-contrib: true
    affiliation: "1" # (Multiple affiliations must be quoted)
  - given-names: Damon
    surname: Toth
    orcid: 0000-0001-7393-4814
    affiliation: "1"
    equal-contrib: false
  - given-names: Jake
    surname: Wagoner
    affiliation: "1"
    orcid: 0009-0000-5053-2281
    equal-contrib: false
  - given-names: Olivia
    surname: Banks
    affiliation: "1"
    equal-contrib: false
    orcid: 0009-0008-7611-6030
affiliations:
 - name: The University of Utah, United States
   index: 1
bibliography: paper.bib
---

## Summary

The `measles` package implements agent-based models for simulating measles outbreaks in school settings and community populations in the R programming language [@R]. The package was developed through collaborations with public health partners during the 2025 measles outbreak in the United States. The package depends on `epiworldR` [@epiworldR;@epiworldRjoss] for its core simulation engine and provides three specialized measles models that users can apply to simulate outbreaks and evaluate the potential effects of different intervention strategies.

## Statement of need

The 2025 US measles outbreak, which began in Texas, has resulted in thousands of cases across the United States. In parallel with the rise of anti-vaccination campaigns, diseases such as measles—previously considered eliminated in many settings—have re-emerged as significant public health concerns. Measles is a highly transmissible yet preventable disease, but declining immunization coverage over the past decade has reduced population immunity below the levels required to prevent outbreaks, which is commonly estimated at approximately 93%, based on a basic reproductive number estimated to be about 15 [@guerraBasicReproductionNumber2017].

Although agent-based models of measles exist, many are not readily accessible to non-expert users or designed for routine use by public health practitioners. During the 2025 outbreak, public health partners explicitly identified the need for a user-friendly, well-documented measles modeling tool that could be used to support decision-making in real time [@InsightNetAnnual].

The models implemented in the `measles` R package were developed and refined through extensive use by public health officials during outbreak response efforts. As a result, the package provides battle-tested, efficient, and well-documented agent-based models that bring advanced modeling capabilities closer to practitioners. By lowering technical barriers, the `measles` package enables epidemiologists and public health officials to explore outbreak dynamics and evaluate intervention strategies using a tool grounded in real-world public health practice.

## State of the field

Measles transmission has been studied using a range of modeling approaches, including agent-based models, compartmental models, and interactive simulators aimed at public health communication and planning. Existing tools differ substantially in their intended audience, accessibility, and extensibility.

Several widely used measles simulators are designed primarily as interactive, practitioner-facing tools. The Framework for Reconstructing Epidemiological Dynamics (FRED) provides an agent-based modeling platform built on synthetic populations with realistic household and school structures and includes a U.S. measles simulator for scenario exploration [@grefenstetteFREDFrameworkReconstructing2013]. The Centers for Disease Control and Prevention (CDC) offers an interactive measles outbreak simulator that supports exploration of outbreak trajectories under different intervention strategies using a stochastic discrete-time compartmental model, but it is primarily intended for communication rather than extensible research workflows [@cdcMeaslesOutbreakSimulator2026]. Similarly, the epiENGAGE measles simulator focuses on accessibility and visualization for school-based outbreaks, rather than reusable modeling components, without implementing interventions other than vaccination [@EpiENGAGEMeaslesOutbreak].

Within the R ecosystem, measles modeling is primarily achieved through general-purpose infectious disease modeling and inference frameworks rather than measles-specific outbreak simulators. Packages such as `pomp` and `panelPomp` include canonical measles examples for methodological development and inference but typically require substantial modeling expertise and project-specific implementation [@hePlugandplayInferenceDisease2009;@panelPompAnalysisPanelData2025].

Overall, existing tools tend to emphasize either accessibility with limited extensibility or flexibility with high technical barriers. This gap highlights the need for a reusable, agent-based measles modeling package that is accessible to applied epidemiologists and public health practitioners working within the R ecosystem.

## Software design

The `measles` package builds upon the `epiworld` C++ library, which provides a general framework for fast agent-based models. This design enables efficient simulation while retaining the flexibility needed for applied outbreak modeling.

All models in `measles` are discrete-time agent-based models that differ in how contacts between agents are represented. The package includes three approaches: a single-school model assuming perfect mixing; a community-level model that uses a mixing matrix to represent within- and between-group interactions; and an extended model that incorporates risk-dependent quarantine durations.

Each model implements the full disease progression of measles, including susceptible, exposed, prodromal, rash, and recovered states, as well as hospitalization and quarantine processes. The API allows users to modify key components such as contact rates, individual susceptibility, index cases, initial conditions, and quarantine policies.

An extended example simulates an outbreak in the southwest region of Utah (Short Creek, a region with low vaccination coverage), integrating school-level vaccination data from the Utah Department of Health and Human Services, population age structure from the U.S. Census, and age-specific mixing patterns from the POLYMOD survey.

![Mixing model architecture in the `measles` package showing entities (e.g., age groups, schools) and their interactions via a mixing matrix. Each entity can have different vaccination rates.](mixing-seir-epiworld.png)

The package and its documentation (vignettes, API references, and help files) are readily available in the Comprehensive R Archive Network (CRAN) and on GitHub at <https://github.com/UofUEpiBio/measles>, where development takes place. Community guidelines, including a code of conduct, are available in the repository.

## Research impact statement

The `measles` R package is the result of intensive collaboration between the University of Utah and the Utah Department of Health and Human Services (DHHS). Using the functions implemented in this package, and with funding from the U.S. Centers for Disease Control and Prevention, the University of Utah developed a Shiny application that has been used extensively by DHHS and other public health departments in the United States.

By mid-2025, DHHS used the school-based models to generate individualized outbreak simulations for every school in the state of Utah. These results were communicated directly to school districts to support preparedness and response planning.

The `measles` package continues to be used through active collaborations with public health partners, including the states of Utah, Minnesota, and Washington, where the models are being used to generate measles outbreak simulations to help inform public health policy.

## AI usage disclosure

Generative AI tools were used in the development of this work. GitHub Copilot was used to assist with portions of the software implementation. ChatGPT was used to assist with drafting and editing parts of this manuscript. All AI-assisted content was reviewed and validated by the authors. In the case of the ChatGPT assisted component, you can review the entire conversation in [this link](https://chatgpt.com/share/698ac27e-9dac-800d-b6de-c5aef213065f).

# Acknowledgements

This work was supported by the Centers for Disease Control and Prevention, Modeling Infectious Diseases in Healthcare Network award U01CK000585 and Insight Net award number CDC-RFA-FT-23-0069.

# References
