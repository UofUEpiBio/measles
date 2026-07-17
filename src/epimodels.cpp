
#include "cpp11.hpp"
#include "cpp11/external_pointer.hpp"
#include "cpp11/matrix.hpp"
#include "epiworld/epiworld.hpp"
#include "measles/measles.hpp"

using namespace cpp11;

[[cpp11::register]]
std::string measles_cpp_version_cpp()
{
    return measles_version();
}

// Measles Model definitions
// Based on epiworld library: https://github.com/UofUEpiBio/epiworld

[[cpp11::register]]
SEXP ModelMeaslesSchool_cpp(
  unsigned int n,
  unsigned int prevalence,
  double contact_rate,
  double transmission_rate,
  double vax_efficacy,
  double vax_reduction_recovery_rate,
  double incubation_period,
  double prodromal_period,
  double rash_period,
  double days_undetected,
  double hospitalization_rate,
  double hospitalization_period,
  double prop_vaccinated,
  int quarantine_period,
  double quarantine_willingness,
  int isolation_period

) {

  // Creating a pointer to a ModelMeaslesSchool model
  cpp11::external_pointer<measles::ModelMeaslesSchool<>> ptr(
      new measles::ModelMeaslesSchool<>(
          n,
          prevalence,
          contact_rate,
          transmission_rate,
          vax_efficacy,
          vax_reduction_recovery_rate,
          incubation_period,
          prodromal_period,
          rash_period,
          days_undetected,
          hospitalization_rate,
          hospitalization_period,
          prop_vaccinated,
          quarantine_period,
          quarantine_willingness,
          isolation_period
      )
  );

  return ptr;

}

[[cpp11::register]]
SEXP ModelMeaslesMixing_cpp(
    unsigned int n,
    double prevalence,
    double transmission_rate,
    double vax_efficacy,
    double vax_reduction_recovery_rate,
    double incubation_period,
    double prodromal_period,
    double rash_period,
    std::vector< double > contact_matrix,
    double hospitalization_rate,
    double hospitalization_period,
    // Policy parameters
    double days_undetected,
    int quarantine_period,
    double quarantine_willingness,
    double isolation_willingness,
    int isolation_period,
    double prop_vaccinated,
    double contact_tracing_success_rate = 1.0,
    unsigned int contact_tracing_days_window = 4u,
    double rash_reduction_contact_rate = 1.0
) {

  // Creating a pointer to a ModelMeaslesMixing model
  cpp11::external_pointer<measles::ModelMeaslesMixing<>> ptr(
      new measles::ModelMeaslesMixing<>(
          n,
          prevalence,
          transmission_rate,
          vax_efficacy,
          vax_reduction_recovery_rate,
          incubation_period,
          prodromal_period,
          rash_period,
          contact_matrix,
          hospitalization_rate,
          hospitalization_period,
          days_undetected,
          quarantine_period,
          quarantine_willingness,
          isolation_willingness,
          isolation_period,
          prop_vaccinated,
          contact_tracing_success_rate,
          contact_tracing_days_window,
          rash_reduction_contact_rate
      )
  );

  return ptr;

}

[[cpp11::register]]
SEXP ModelMeaslesMixingRiskQuarantine_cpp(
    unsigned int n,
    double prevalence,
    double transmission_rate,
    double vax_efficacy,
    double incubation_period,
    double prodromal_period,
    double rash_period,
    std::vector< double > contact_matrix,
    double hospitalization_rate,
    double hospitalization_period,
    // Policy parameters
    double days_undetected,
    int quarantine_period_high,
    int quarantine_period_medium,
    int quarantine_period_low,
    double quarantine_willingness,
    double isolation_willingness,
    int isolation_period,
    double prop_vaccinated,
    double detection_rate_quarantine,
    double contact_tracing_success_rate = 1.0,
    unsigned int contact_tracing_days_window = 4u
) {

  // Creating a pointer to a ModelMeaslesMixingRiskQuarantine model
  cpp11::external_pointer<measles::ModelMeaslesMixingRiskQuarantine<>> ptr(
      new measles::ModelMeaslesMixingRiskQuarantine<>(
          n,
          prevalence,
          transmission_rate,
          vax_efficacy,
          incubation_period,
          prodromal_period,
          rash_period,
          contact_matrix,
          hospitalization_rate,
          hospitalization_period,
          days_undetected,
          quarantine_period_high,
          quarantine_period_medium,
          quarantine_period_low,
          quarantine_willingness,
          isolation_willingness,
          isolation_period,
          prop_vaccinated,
          detection_rate_quarantine,
          contact_tracing_success_rate,
          contact_tracing_days_window
      )
  );

  return ptr;

}
