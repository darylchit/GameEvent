if receipt.present?
  object receipt
  extends 'api/v2/receipts/base'
else
  node(:status) do
    404
  end
end
