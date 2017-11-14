require 'csv'

class CsvExporter

  def export(name, data)
    fields = CSV_EXPORT_FIEDLS[name.to_sym]
    results = CSV.generate col_sep: ',' do |csv|
      csv << column_names(name, fields)
      data.each do |row|
        csv << fields.map { |field| row.send(field) }
      end
    end
  end

  private

    def column_names(name, fields)
      fields.map do |field|
        I18n.t("csv.export.#{name}.#{field}")
      end
    end
end