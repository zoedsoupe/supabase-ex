defmodule Supabase.Storage.Endpoints do
  @moduledoc "Defines the Endpoints for the Supabase Storage API"

  def bucket_path do
    "/storage/v1/bucket"
  end

  def bucket_path_with_id(id) do
    "/storage/v1/bucket/#{id}"
  end

  def bucket_path_to_empty(id) do
    bucket_path_with_id(id) <> "/empty"
  end

  def file_upload_url(path) do
    "/storage/v1/object/upload/sign/#{path}"
  end

  def file_move do
    "/storage/v1/object/move"
  end

  def file_copy do
    "/storage/v1/object/copy"
  end

  def file_upload(bucket, path) do
    "/storage/v1/object/#{bucket}/#{path}"
  end

  def file_info(bucket, wildcard) do
    "/storage/v1/object/info/authenticated/#{bucket}/#{wildcard}"
  end

  def file_list(bucket) do
    "/storage/v1/object/list/#{bucket}"
  end

  def file_remove(bucket) do
    "/storage/v1/object/#{bucket}"
  end

  def file_signed_url(bucket, path) do
    "/storage/v1/object/sign/#{bucket}/#{path}"
  end

  def file_download(bucket, wildcard) do
    "/storage/v1/object/authenticated/#{bucket}/#{wildcard}"
  end
end
