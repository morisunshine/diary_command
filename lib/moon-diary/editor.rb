require 'fileutils'
require 'tempfile'
require 'json'
require 'date'
require 'highline/import'

module DiaryEditor
	class Diary
		CONFIGURATION_FILE = File.expand_path("~/.oneday")
		attr_accessor :configuration
		def initialize(*args, opts)
			time = Time.new
			@day = time.day
			@month =  time.month
			@year = time.year
		end

		def run
			configure
			create_diary
		end
		
		def configure
			FileUtils.touch(CONFIGURATION_FILE) unless File.exist?(CONFIGURATION_FILE)
			@configuration = JSON::load(File.open(CONFIGURATION_FILE)) || {}
			diary_path unless @configuration['path']
		end

		def diary_path
			path = ask("You should input the directory of diary.") { |q| q.default = "none" }
			@configuration['path'] = path
			create_directory(path)
			write_configuration
		end
        def create_directory(path)
			say path
			unless File.directory?(path)
				FileUtils.mkdir_p(path)
			end
		end
		def create_diary
			diary_path = "#{create_month_dir}/#{@year}-#{@month}-#{@day}.md"

			FileUtils.touch(diary_path) unless File.exist?(diary_path)
			# content = File.open(diary_path, "w") do |file|
			# 	file.write "记录今日\n ===="
			# end

            cmd = ["vim", '--nofork', diary_path].join(' ')
	        system(cmd) or raise SystemCallError, "`#{cmd}` gave exit status: #{$?.exitstatus}"
	        save_to_dayone(diary_path)
		end

		def save_to_dayone(file_path)
			cmd = ["dayone", 'new <', file_path].join(' ')
			system(cmd) or raise SystemCallError, "`#{cmd}` gave exit status: #{$?.exitstatus}"
		end

		def create_month_dir
			month_dir = "#{create_year_dir}/#{@month}月"
			
			unless File.directory?(month_dir)
				FileUtils.mkdir_p(month_dir)
			end
			month_dir
		end

		def create_year_dir
			year_dir = "#{@configuration['path']}/#{@year}"

			unless File.directory?(year_dir)
				FileUtils.mkdir_p(year_dir)
			end
			year_dir
		end

		
		def write_configuration
			File.open(CONFIGURATION_FILE, "w") do |file|
				file.write @configuration.to_json
		  end
		end

	end
end
