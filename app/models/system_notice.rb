class SystemNotice < Notice
  belongs_to :admin
  validates_presence_of :admin_id, :message => "Required"
end
