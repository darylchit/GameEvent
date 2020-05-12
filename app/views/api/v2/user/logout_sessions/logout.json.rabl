if @user_setting
  node(:status) do
    :ok
  end
else
  node(:status) do
    422
  end
end
