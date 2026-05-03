class CreateKubeStationConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :kube_station_configs do |t|
      t.string :name, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end

    add_index :kube_station_configs, :name, unique: true
  end
end
