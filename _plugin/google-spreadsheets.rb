require 'google_drive'
require 'fileutils'
require 'time'
require 'date'
require 'yaml'

module Jekyll
  class ProgramData < Generator
    def generate(site)
      if site.config['spreadsheets'] == nil
        return Jekyll.logger.warn "Google spreadsheet data not generated, because 'spreadsheets' is not defined in _config.yml"
      end

      # Re-using sass-cache directory that suppose to be ignored from file watching and is cleaned with `jekyll clean`
      cacheDir = "#{site.source}/.sass-cache"
      if not File.directory? cacheDir
        FileUtils::mkdir_p cacheDir
      end

      if site.config['spreadsheets']['google_client_id'] == nil
        return Jekyll.logger.warn "Google spreadsheet data not generated, because 'spreadsheets.google_client_id' is not defined in _config.yml"
      end

      if site.config['spreadsheets']['spreadsheet'] == nil
        return Jekyll.logger.warn "Google spreadsheet data not generated, because 'spreadsheets.spreadsheet' is not defined in _config.yml"
      end

      begin
        session = GoogleDrive::Session.from_config(site.config['spreadsheets']['google_client_id'])
        Jekyll.logger.info 'Generating data from Google spreadsheets...'
        site.data['spreadsheets'] = {}
        site.data['spreadsheets_updated'] = {}

        for sheetKey in site.config['spreadsheets']['spreadsheet']
          begin
            Jekyll.logger.warn '   from spreadsheet ', sheetKey
            spreadsheet = session.spreadsheet_by_key(sheetKey)

            for ws in spreadsheet.worksheets
              file = "#{cacheDir}/#{ws.title}.yml"
              fileMeta = "#{file}.meta"

              site.data['spreadsheets_updated'][ws.title] = ws.updated.to_s
              Jekyll.logger.warn ws.updated.class
              Jekyll.logger.warn ws.updated
              
              if File.exist?(file) and File.exist?(fileMeta)
                updated = Time.parse(File.read(fileMeta))
                if ws.updated.to_i <= updated.to_i
                  site.data['spreadsheets'][ws.title] = YAML.load_file(file)
                  next
                end
              end

              begin
                list = []
                ws.list.each do |item|
                  list << item.to_hash
                end

                site.data['spreadsheets'][ws.title] = list
                File.write file, list.to_yaml
                File.write fileMeta, ws.updated
              rescue
                Jekyll.logger.warn "Error processing worksheet: ", $!
              end
            end
          rescue
            Jekyll.logger.warn "Error processing spreadsheet: ", $!
          end
        end
      rescue
        return Jekyll.logger.error "Failed to process Google spreadsheets", $!
      end
    end
  end
end
