namespace :subscription do
  task extend: :environment do
    Subscriptions::Extend.call
  end
end
