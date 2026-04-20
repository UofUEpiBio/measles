
#include "cpp11.hpp"
#include "cpp11/external_pointer.hpp"
#include "cpp11/matrix.hpp"
#include "epiworld/epiworld.hpp"
#include "measles/measles.hpp"

using namespace cpp11;

[[cpp11::register]]
SEXP InterventionMeaslesPEP_cpp(
    std::string name,
    double mmr_efficacy,
    double ig_efficacy,
    double ig_half_life_mean,
    double ig_half_life_sd,
    double mmr_willingness,
    double ig_willingness,
    double mmr_window,
    double ig_window,
    std::vector< int > target_states,
    std::vector< int > states_if_pep_effective,
    std::vector< int > states_if_pep_ineffective
) {

  cpp11::external_pointer<measles::InterventionMeaslesPEP<>> ptr(
      new measles::InterventionMeaslesPEP<>(
          name,
          mmr_efficacy,
          ig_efficacy,
          ig_half_life_mean,
          ig_half_life_sd,
          mmr_willingness,
          ig_willingness,
          mmr_window,
          ig_window,
          target_states,
          states_if_pep_effective,
          states_if_pep_ineffective
      )
  );

  return ptr;

}
