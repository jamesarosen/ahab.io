namespace :assets do

  desc 'Compile assets'
  task :compile => :fetch

  # For Heroku:
  task :precompile => :compile

  directory 'public'

  def copy_asset_task(name)
    infile  = "lib/assets/#{name}"
    outfile = "public/#{name}"

    copy_task = file(outfile => [infile, 'public']) do |task|
      FileUtils.cp(task.prerequisites.first, task.name)
      puts "Wrote #{task.name}"
    end

    task :compile => copy_task
  end

  Dir.glob('lib/assets/*.png').each do |png|
    copy_asset_task png.sub('lib/assets/', '')
  end

  Dir.glob('lib/assets/*.js').each do |js|
    copy_asset_task js.sub('lib/assets/', '')
  end

  def asset_concatenation_task(name, *infiles)
    task_name = "public/#{name}"

    concatenation_task = file(task_name => infiles + ['public']) do |task|
      quoted_infile_list = infiles.map { |f| "\"#{f}\"" }.join(' ')
      puts quoted_infile_list
      sh "cat #{quoted_infile_list} > #{task.name}"
    end

    task :compile => concatenation_task
  end

  asset_concatenation_task 'vendor.css', 'vendor/assets/960_12_col.css', 'vendor/assets/jquery-ui.css'
  asset_concatenation_task 'vendor.js', 'vendor/assets/jquery.min.js', 'vendor/assets/handlebars.min.js', 'vendor/assets/jquery-ui.min.js'
  asset_concatenation_task 'jquery.min.map', 'vendor/assets/jquery.min.map'

  def sass_task(name)
    infile  = "lib/assets/#{name}.scss"
    outfile = "public/#{name}.css"

    compilation_task = file(outfile => [infile, 'public']) do |task|
      require 'sass'
      css = Sass::compile_file(infile)
      File.write(task.name, css)
      puts "Wrote #{task.name}"
    end

    task :compile => compilation_task
  end

  sass_task 'application'

end
