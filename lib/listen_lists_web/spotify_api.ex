defmodule SpotifyApi do
  @base_url "https://accounts.spotify.com/api"

  def get_access_token(client_id, client_secret) do
    body = %{grant_type: "client_credentials"}
    headers = [{"Authorization", "Basic " <> Base.encode64("#{client_id}:#{client_secret}")},
  {"Content-Type", "application/x-www-form-urlencoide"}]

    case HTTPoison.post("#{@base_url}/token", {:form, body}, headers) do
      {:ok, %{body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} -> {:ok, decoded_body["access_token"]}
          {:error, reason} -> {:error, reason}
        end
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
      {:error, %HTTPoison.Response{status_code: code}} ->
        {:error, "HTTP Error #{code}"}
    end
  end

  def get_auth_header(token) do
    {"Authorization", "Bearer " <> token}
  end

  def search_for_album(token, album) do
    url = "https://api.spotify.com/v1/search"
    headers = [get_auth_header(token)]
    query = "?q=#{URI.encode_www_form(album)}&type=album&limit=10"

    query_url = url <> query

    case HTTPoison.get(query_url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, decoded_body} -> {:ok, decoded_body}
          {:error, reason} -> {:error, reason}
        end
      {:ok, %{status_code: code, body: _body}} ->
        {:error, "HTTP Error #{code}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

end
