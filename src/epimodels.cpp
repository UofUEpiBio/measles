#include "cpp11.hpp"
#include "cpp11/external_pointer.hpp"
#include "epiworld/epiworld.hpp"
#include "measles/measles.hpp"

using namespace cpp11;

[[cpp11::register]]
std::string measles_cpp_version_cpp()
{
    return measles_version();
}

// The measles models are built by their registry entries
// (measles::register_models()), which check the values of the arguments.
static const epiworld::ModelRegistry & registry() {

  static const epiworld::ModelRegistry reg = [] {
    epiworld::ModelRegistry r;
    measles::register_models(r);
    return r;
  }();

  return reg;

}

[[cpp11::register]]
SEXP make_model_cpp(std::string id, cpp11::doubles values) {

  std::map< std::string, double > v;
  if (values.size() > 0)
  {
    cpp11::strings names(values.names());
    for (R_xlen_t i = 0; i < values.size(); ++i)
      v[std::string(names[i])] = values[i];
  }

  return cpp11::external_pointer<epiworld::Model>(
    registry().make_model(id, v, "").release()
  );

}
