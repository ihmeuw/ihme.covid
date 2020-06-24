#' Binds together the PDFs from an array job - is called by 'pdf_array_job()'.
#'
bind_pdfs = function(temp_out_dir, final_out_dir, write_file_name){
  files = list.files(temp_out_dir, full.names=T, include.dirs=F)
  
  # Add zeros to job ID so they will sort in the order of jobs file
  file_order = data.table::data.table(file = files)
  file_order[, job_id:=gsub(paste0(temp_out_dir, "/"), "", files)]
  file_order[, job_id:=gsub(".png", "", job_id)]
  file_order = file_order[order(as.numeric(job_id))]
  
  pdf(paste0(final_out_dir, "/", write_file_name))
  for (file in file_order$file){
    grob = grid::rasterGrob(png::readPNG(file, native = FALSE), interpolate = FALSE)
    gridExtra::grid.arrange(grob)
  }
  dev.off()
}

parser <- argparse::ArgumentParser()
parser$add_argument("--temp-out-dir", required=TRUE, help="Temporary directory where files are saved")
parser$add_argument("--final-out-dir", required=TRUE, help="Final directory to save files in")
parser$add_argument("--write-file-name", required=TRUE, help="Final PDF name to write")
args <- parser$parse_args()

temp_out_dir = args$temp_out_dir
final_out_dir = args$final_out_dir
write_file_name = args$write_file_name

bind_pdfs(temp_out_dir, final_out_dir, write_file_name)
