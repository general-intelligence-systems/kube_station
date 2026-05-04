TurboFrame(id: "node-panel") {
  if @node
    meta = @node[:metadata]
    spec = @node[:spec]
    status = @node[:status]

    Header(size: 4) { text meta[:name] }

    Table(celled: true, compact: true, definition: true) {
      TableBody {
        TableRow {
          TableCell { text "Kind" }
          TableCell { text @kind }
        }
        TableRow {
          TableCell { text "Namespace" }
          TableCell { text meta[:namespace] || "—" }
        }
        TableRow {
          TableCell { text "UID" }
          TableCell { Wrapper(class: "uid") { text meta[:uid] } }
        }
        TableRow {
          TableCell { text "Created" }
          TableCell { text meta[:creationTimestamp] }
        }

        if meta[:labels]&.any?
          TableRow {
            TableCell { text "Labels" }
            TableCell {
              meta[:labels].each do |k, v|
                Label(size: :small) { text "#{k}: #{v}" }
              end
            }
          }
        end

        if meta[:ownerReferences]&.any?
          TableRow {
            TableCell { text "Owners" }
            TableCell {
              meta[:ownerReferences].each do |ref|
                Label(size: :small) { text "#{ref[:kind]}/#{ref[:name]}" }
              end
            }
          }
        end

        if status&.dig(:phase)
          TableRow {
            TableCell { text "Phase" }
            TableCell { text status[:phase] }
          }
        end
      }
    }
  else
    Message { text "Node not found" }
  end
}
