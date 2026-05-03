class CreateKubeStationClusters < ActiveRecord::Migration[8.1]
  def change
    create_table :kube_station_clusters do |t|
      t.string :name, null: false
      t.references :config, null: false, foreign_key: { to_table: :kube_station_configs }

      t.timestamps
    end

    add_index :kube_station_clusters, [ :name, :config_id ], unique: true
  end
end
