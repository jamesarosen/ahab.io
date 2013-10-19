namespace :assets do

  desc 'Compile assets'
  task :compile => :fetch

  def asset_concatenation_task(name, *infiles)
    task_name = "public/#{name}"

    concatenation_task = file(task_name => infiles) do |task|
      quoted_infile_list = infiles.map { |f| "\"#{f}\"" }.join(' ')
      sh "cat #{quoted_infile_list} > #{task.name}"
    end

    task :compile => concatenation_task
  end

  asset_concatenation_task 'vendor.css', 'vendor/assets/960_12_col.css'

  def sass_task(name)
    infile  = "lib/assets/#{name}.scss"
    outfile = "public/#{name}.css"

    compilation_task = file(outfile => infile) do |task|
      require 'sass'
      css = Sass::compile_file(infile)
      File.write(task.name, css)
      puts "Wrote #{task.name}"
    end

    task :compile => compilation_task
  end

  sass_task 'application'

end