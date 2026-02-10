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
  - given-name: Olivia
    surname: Banks
    affiliation: "1"
    orcid: 0009-0008-7611-6030
affiliations:
 - name: The University of Utah, United States
   index: 1
bibliography: paper.bib
---

## Summary

The R package **measles** implements agent-based models for simulating measles outbreaks in school settings and community populations. The package was developed through collaborations with public health partners during the 2025 measles outbreak in the United States. Built on top of **epiworldR**, **measles** provides three models that users can apply to simulate outbreaks and evaluate the potential effects of different intervention strategies.

## Statement of need

The 2025 measles outbreak, which began in Texas, resulted in thousands of cases across the United States. In parallel with the rise of anti-vaccination campaigns, diseases such as measles—previously considered eliminated in many settings—have re-emerged as significant public health concerns. Measles is a highly transmissible yet preventable disease, but declining immunization coverage over the past decade has reduced population immunity below the levels required to prevent outbreaks.

Although agent-based models of measles exist, many are not readily accessible to non-expert users or designed for routine use by public health practitioners. During the 2025 outbreak, public health partners explicitly identified the need for a user-friendly, well-documented measles modeling tool that could be used to support decision-making in real time.

The models implemented in the **measles** R package were developed and refined through extensive use by public health officials during outbreak response efforts. As a result, the package provides battle-tested, performant, and well-documented agent-based models that bring advanced modeling capabilities closer to practitioners. By lowering technical barriers, the **measles** package enables epidemiologists and public health officials to explore outbreak dynamics and evaluate intervention strategies using a tool grounded in real-world public health practice.

With support from the Centers for Disease Control and Prevention, development of the **measles** package will continue, adding new features motivated by ongoing measles outbreaks worldwide.

## State of the field

Measles transmission has been studied using a range of modeling approaches, including agent-based models, compartmental models, and interactive simulators aimed at public health communication and planning. Existing tools differ substantially in their intended audience, accessibility, and extensibility.

Several widely used measles simulators are designed primarily as interactive, practitioner-facing tools. The Framework for Reconstructing Epidemiological Dynamics (FRED) provides an agent-based modeling platform built on synthetic populations with realistic household and school structures and includes a U.S. measles simulator for scenario exploration (Grefenstette et al., 2013). The Centers for Disease Control and Prevention (CDC) offers an interactive measles outbreak simulator that supports exploration of outbreak trajectories under different intervention strategies, but it is not agent-based and is primarily intended for communication rather than extensible research workflows (CDC, 2024). Similarly, the epiENGAGE measles simulator focuses on accessibility and visualization for school-based outbreaks, rather than reusable modeling components (epiENGAGE, 2024).

In the academic literature, agent-based and hybrid models have been used to study measles transmission dynamics and evaluate vaccination strategies in heterogeneous populations (Ajelli et al., 2010; Perez & Dragicevic, 2009). While these models demonstrate the flexibility of agent-based approaches, they are often developed as bespoke research code and are not distributed as reusable software for applied users.

Within the R ecosystem, measles modeling is largely supported through general-purpose infectious disease modeling and inference frameworks rather than measles-specific outbreak simulators. Packages such as **pomp** and **panelPomp** include canonical measles examples for methodological development and inference but typically require substantial modeling expertise and project-specific implementation (King et al., 2008; He et al., 2010; Bretó et al., 2023). Other R tools focus on retrospective analysis of measles surveillance data rather than forward simulation of outbreaks (Salje et al., 2020).

Overall, existing tools tend to emphasize either accessibility with limited extensibility or flexibility with high technical barriers. This gap motivates the need for a reusable, agent-based measles modeling package that is accessible to applied epidemiologists and public health practitioners working within the R ecosystem.

### References

Ajelli, M., Merler, S., Pugliese, A., & Rizzo, C. (2010). Model-based assessment of the impact of vaccination campaigns on the transmission of measles. *Vaccine*, 28(37), 6095–6101.

Bretó, C., Ionides, E. L., & King, A. A. (2023). Panel data inference for partially observed Markov processes. *Journal of the Royal Statistical Society: Series C*, 72(1), 1–23.

Centers for Disease Control and Prevention. (2024). *Interactive measles outbreak simulator*. U.S. Department of Health and Human Services.

epiENGAGE. (2024). *Measles outbreak simulator*. Texas Advanced Computing Center.

Grefenstette, J. J., Brown, S. T., Rosenfeld, R., et al. (2013). FRED (A Framework for Reconstructing Epidemiological Dynamics): An open-source software system for modeling infectious diseases using census-based populations. *BMC Public Health*, 13, 940.

He, D., Ionides, E. L., & King, A. A. (2010). Plug-and-play inference for disease dynamics: Measles in large and small populations as a case study. *Journal of the Royal Society Interface*, 7(43), 271–283.

King, A. A., Ionides, E. L., Pascual, M., & Bouma, M. J. (2008). Inapparent infections and cholera dynamics. *Nature*, 454(7206), 877–880.

Perez, L., & Dragicevic, S. (2009). An agent-based approach for modeling dynamics of contagious disease spread. *International Journal of Health Geographics*, 8, 50.

Salje, H., Lessler, J., Endy, T. P., et al. (2020). Reconstructing transmission clusters from surveillance data. *Proceedings of the National Academy of Sciences*, 117(1), 549–558.

## Software design

The **measles** package is built on top of **epiworld**, a C++ library that provides a general framework for fast agent-based models. This design enables efficient simulation while retaining the flexibility needed for applied outbreak modeling.

All models in **measles** are discrete-time agent-based models that differ in how contacts between agents are represented. The package includes three approaches: a single-school model assuming perfect mixing; a community-level model that uses a mixing matrix to represent within- and between-group interactions; and an extended model that incorporates risk-dependent quarantine durations.

Each model implements the full disease progression of measles, including susceptible, exposed, prodromal, rash, and recovered states, as well as hospitalization and quarantine processes. The application programming interface allows users to modify key components such as contact rates, individual susceptibility, index cases, initial conditions, and quarantine policies.

An extended example is included that simulates an outbreak in the southwest region of Utah (Short Creek), integrating school-level vaccination data from the Utah Department of Health and Human Services, population age structure from the U.S. Census, and age-specific mixing patterns from the POLYMOD survey.

## Research impact statement

The **measles** R package is the result of intensive collaboration between the University of Utah and the Utah Department of Health and Human Services (DHHS). Using the functions implemented in this package, and with funding from the U.S. Centers for Disease Control and Prevention, the University of Utah developed a Shiny application that has been used extensively by DHHS and other public health departments in the United States.

In addition, by mid-2025, DHHS used the school-based models to generate individualized outbreak simulations for every school in the state of Utah. These results were communicated directly to school districts to support preparedness and response planning.

Ongoing use of the **measles** package continues through active collaborations with public health partners, including the states of Utah, Minnesota, and Washington, where the models are being used to generate measles outbreak simulations to help inform public health policy.

## AI usage disclosure

Generative AI tools were used in the development of this work. GitHub Copilot was used to assist with portions of the software implementation. ChatGPT was used to assist with drafting and editing parts of this manuscript. All AI-assisted content was reviewed and validated by the authors. In the case of the ChatGPT assisted component, you can review the entire conversation in [this link](https://chatgpt.com/share/698ac27e-9dac-800d-b6de-c5aef213065f).
