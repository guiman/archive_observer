class AddNewLanguageIndexes < ActiveRecord::Migration
  def self.up
    remove_index :languages, name: "lang_name_idx"
    add_index :languages, :name, unique: true
  end

  def self.down
    remove_index :languages, :name
    add_index "languages", ["name"], name: "lang_name_idx", using: :btree
  end
end
