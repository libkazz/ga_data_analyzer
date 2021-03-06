class GaDataAnalyzer
  module Importer
    BULK_BATCH_SIZE = 500

    class << self
      def import!(lines)
        create_table!
        import_lines_in_batch!(lines)
      end

      private

      def create_table!
        ActiveRecord::Migration.create_table :ga_lines do |t|
          t.string :duration,    null: false
          t.string :path,        null: false
          t.string :page_type,   null: false
          t.string :sub_category
          t.string :path1
          t.string :path2
          t.string :path3
          t.string :path4
          t.string :path5
          t.integer :session,    null: false
        end
      end

      def import_lines_in_batch!(lines)
        query = "INSERT INTO ga_lines\n"
        query << "SELECT NULL,#{LineParser.parse(lines[0]).to_query}\n"
        lines[1..BULK_BATCH_SIZE - 1].each do |line|
          query << "UNION ALL SELECT NULL,#{LineParser.parse(line).to_query}\n"
        end
        ActiveRecord::Base.connection.execute(query)

        import_lines_in_batch!(lines[BULK_BATCH_SIZE..-1]) if lines.size > BULK_BATCH_SIZE
      end
    end
  end
end
