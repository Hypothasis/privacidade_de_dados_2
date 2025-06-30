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

ActiveRecord::Schema[7.2].define(version: 2025_06_30_140058) do
  create_table "animals", force: :cascade do |t|
    t.float "epsilon"
    t.string "animal"
    t.float "count"
    t.float "porcent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "histograma_racas", force: :cascade do |t|
    t.float "epsilon"
    t.string "cidade"
    t.float "parda_count"
    t.float "amarela_count"
    t.float "branca_count"
    t.float "preta_count"
    t.float "indigena_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "histrograma_gerals", force: :cascade do |t|
    t.float "epsilon"
    t.float "decada_10"
    t.float "decada_20"
    t.float "decada_30"
    t.float "decada_40"
    t.float "decada_50"
    t.float "decada_60"
    t.float "decada_70"
    t.float "decada_80"
    t.float "decada_90"
    t.float "decada_2000"
    t.float "decada_2010"
    t.float "decada_2020"
    t.float "soma_total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "racas_probs", force: :cascade do |t|
    t.float "epsilon"
    t.float "parda"
    t.float "amarela"
    t.float "branca"
    t.float "preta"
    t.float "indigena"
    t.float "sim_parda"
    t.float "sim_branca"
    t.float "sim_amarela"
    t.float "sim_preta"
    t.float "sim_indigena"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end
end
