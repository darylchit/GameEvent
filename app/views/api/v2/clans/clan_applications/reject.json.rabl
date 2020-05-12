if clan_application.present?
  object clan_application
  attributes :id, :clan_id, :status, :created_at
  node(:applicant) do|application|
   application.user.username
  end
  node(:clan_cover_image) do |application|
    application.clan.cover_url_with_domain
  end
  node(:reviewer) do |application|
    application.reviewer.try(:username)
  end
  attributes :reviewed_at
  child(:answers, :object_root => false) do
    node(:question) do |answer|
      answer.question.name
    end
    attributes :answer
  end
else
  node(:status){ 'Not Found' }
  node(:code) { 404 }
end
