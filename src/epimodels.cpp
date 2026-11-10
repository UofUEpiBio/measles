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

// The measles models share ModelMeasles, which holds who is exempt from
// quarantine
static measles::ModelMeasles & as_measles_model(SEXP model) {

  cpp11::external_pointer<epiworld::Model> ptr(model);
  auto * m = dynamic_cast< measles::ModelMeasles * >(ptr.get());
  if (m == nullptr)
    cpp11::stop("The model is not a measles model.");

  return *m;

}

[[cpp11::register]]
SEXP set_quarantine_exempt_tools_cpp(SEXP model, cpp11::strings tools) {

  std::vector< std::string > names;
  for (R_xlen_t i = 0; i < tools.size(); ++i)
    names.push_back(std::string(tools[i]));

  as_measles_model(model).set_quarantine_exempt_tools(names);
  return model;

}

[[cpp11::register]]
cpp11::strings get_quarantine_exempt_tools_cpp(SEXP model) {

  cpp11::writable::strings out;
  for (const auto & name : as_measles_model(model).get_quarantine_exempt_tools())
    out.push_back(name);

  return out;

}
