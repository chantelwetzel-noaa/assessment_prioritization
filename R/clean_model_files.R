#' Function to delete un-needed Stock Synthesis files
#'
#' @param loc file location where folders needing clearn up are
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' loc = "model_files/"
#'
#'
clean_model_files <- function(loc) {

	dir_list <- list.dirs(loc)[-1]

	files_to_keep <- c(
		"CompReport.sso",
		"control.ss_new",
		"data.ss_new",
		"forecast.ss",
		"starter.ss",
		"Forecast-Report.sso",
		"Report.sso",
		"ss.par", 
		"covar.sso",
		"wtatage.ss_new",
		"warning.sso"
	)

	for(a in 1:length(dir_list)){
		all <- list.files(dir_list[a])
		remove <- !all %in% files_to_keep
		file.remove(file.path(dir_list[a], all[remove]))
	}


}