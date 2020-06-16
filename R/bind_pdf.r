#' Binds together the PDFs from an array job - is called by 'pdf_array_job()'. 
#'
bind_pdfs = function(temp_out_dir, final_out_dir, write_file_name){
  require(grid)
  require(gridExtra)
  require(png)
  
  files = list.files(temp_out_dir, full.names=T, include.dirs=F)
  
  pdf(paste0(final_out_dir, "/", write_file_name))
  for (file in files){
    grob = rasterGrob(readPNG(file, native = FALSE), interpolate = FALSE)
    grid.arrange(grob)
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

print(paste0("Temporary output directory: ", temp_out_dir))
print(paste0("Final output directory: ", final_out_dir))
print(paste0("File name to write: ", write_file_name))

bind_pdfs(temp_out_dir, final_out_dir, write_file_name)