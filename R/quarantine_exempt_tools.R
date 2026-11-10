#' Who is exempt from quarantine
#'
#' In the measles models, an agent holding any of the exempt tools is not
#' quarantined when traced as a contact or when their group is exposed.
#'
#' @param model A measles model ([ModelMeaslesSchool], [ModelMeaslesMixing]
#' or [ModelMeaslesMixingRiskQuarantine]).
#' @param tools Character vector. The names of the tools whose holders are
#' exempt (possibly empty: nobody is exempt).
#' @details
#' The tools are matched by name, and exempt their holders whether or not
#' they protect them: documented MMR vaccination, routine or as post-exposure
#' prophylaxis, is presumptive evidence of immunity, while immunoglobulin is
#' not (CDC, Manual for the Surveillance of Vaccine-Preventable Diseases,
#' Chapter 7). The default is `c("MMR", "PEP MMR")`: the models' vaccine and
#' the MMR given by [InterventionMeaslesPEP]. Holders of other tools,
#' including immunoglobulin ("PEP IG") and tools added with
#' [epiworldR::add_tool()], are quarantined unless their tool is listed. A
#' name that no tool has exempts no one.
#'
#' Recovered agents and agents with rash are never quarantined, whatever
#' tools they hold.
#' @returns
#' - `set_quarantine_exempt_tools()` returns the model, invisibly.
#' - `get_quarantine_exempt_tools()` returns the names of the exempt tools.
#' @examples
#' model <- ModelMeaslesSchool(n = 500, prevalence = 1)
#' get_quarantine_exempt_tools(model)
#'
#' # Immunoglobulin recipients are also exempt
#' set_quarantine_exempt_tools(model, c("MMR", "PEP MMR", "PEP IG"))
#' get_quarantine_exempt_tools(model)
#' @export
set_quarantine_exempt_tools <- function(model, tools) {

  if (!inherits(model, "epiworld_model")) {
    stop("`model` must be a measles model.")
  }

  if (!is.character(tools) || anyNA(tools)) {
    stop("`tools` must be a character vector without missing values.")
  }

  invisible(set_quarantine_exempt_tools_cpp(model, tools))

}

#' @rdname set_quarantine_exempt_tools
#' @export
get_quarantine_exempt_tools <- function(model) {

  if (!inherits(model, "epiworld_model")) {
    stop("`model` must be a measles model.")
  }

  get_quarantine_exempt_tools_cpp(model)

}
