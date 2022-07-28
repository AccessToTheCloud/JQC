class AddSearchIndexesToRefNumbers < ActiveRecord::Migration[6.0]
  def change
    add_index :applications,
              :reference_number,
              type: :fulltext

    add_index :applications,
              :converted_to_from,
              type: :fulltext
  end
end
