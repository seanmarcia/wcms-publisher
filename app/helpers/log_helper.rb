module LogHelper
  def logs(obj, options = {})
    logs = []
    logs << obj.history_tracks.to_a
    logs << ActivityLog.for_associated(obj).to_a
    logs.flatten!.sort!{ |a,b| b.created_at <=> a.created_at }
  end
end
