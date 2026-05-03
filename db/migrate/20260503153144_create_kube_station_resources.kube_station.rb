# This migration comes from kube_station (originally 20260503000003)
class CreateKubeStationResources < ActiveRecord::Migration[8.1]
  def change
    create_table :kube_station_resources do |t|
      t.string :kind, null: false
      t.references :cluster, null: false, foreign_key: { to_table: :kube_station_clusters }

      t.timestamps
    end

    add_index :kube_station_resources, [ :kind, :cluster_id ], unique: true
  end
end
