# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_03_155208) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "kube_station_clusters", force: :cascade do |t|
    t.bigint "config_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["config_id"], name: "index_kube_station_clusters_on_config_id"
    t.index ["name", "config_id"], name: "index_kube_station_clusters_on_name_and_config_id", unique: true
  end

  create_table "kube_station_configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_kube_station_configs_on_name", unique: true
  end

  create_table "kube_station_resources", force: :cascade do |t|
    t.bigint "cluster_id", null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.datetime "updated_at", null: false
    t.index ["cluster_id"], name: "index_kube_station_resources_on_cluster_id"
    t.index ["kind", "cluster_id"], name: "index_kube_station_resources_on_kind_and_cluster_id", unique: true
  end

  add_foreign_key "kube_station_clusters", "kube_station_configs", column: "config_id"
  add_foreign_key "kube_station_resources", "kube_station_clusters", column: "cluster_id"
end
