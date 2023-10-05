defmodule Supabase.Storage do
  @moduledoc """
  Supabase.Storage Elixir Package

  This module provides integration with the Supabase Storage API, enabling developers
  to perform a multitude of operations related to buckets and objects with ease.

  ## Features

  1. **Bucket Operations**: Methods that allow the creation, listing, and removal of buckets.
  2. **Object Operations**: Functions designed to upload, download, retrieve object information,
     and perform move, copy, and remove actions on objects.

  ## Usage

  You can start by creating or managing buckets:

      Supabase.Storage.create_bucket(conn, "my_new_bucket")

  Once a bucket is set up, objects within the bucket can be managed:

      Supabase.Storage.upload_object(conn, "my_bucket", "path/on/server.png", "path/on/local.png")

  ## Examples

  Here are some basic examples:

      # Removing an object
      Supabase.Storage.remove_object(conn, "my_bucket", "path/on/server.png")

      # Moving an object
      Supabase.Storage.move_object(conn, "my_bucket", "path/on/server1.png", "path/on/server2.png")

  Ensure to refer to method-specific documentation for detailed examples and explanations.

  ## Permissions

  Do remember to check and set the appropriate permissions in Supabase to make sure that the
  operations can be performed without any hitches.
  """

  # import Supabase.Connection

  alias Supabase.Storage.Bucket
  alias Supabase.Storage.BucketHandler
  alias Supabase.Storage.Object
  alias Supabase.Storage.ObjectHandler
  alias Supabase.Storage.ObjectOptions
  alias Supabase.Storage.SearchOptions

  @behaviour Supabase.StorageBehaviour

  @doc """
  Retrieves information about all buckets in the current project.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: `select`
    * `objects` permissions: none

  ## Examples

      iex> Supabase.Storage.list_buckets(conn)
      {:ok, [%Supabase.Storage.Bucket{...}, ...]}

      iex> Supabase.Storage.list_buckets(invalid_conn)
      {:error, reason}

  """
  @impl true
  def list_buckets(conn) do
    base_url = ""
    api_key = ""
    token = ""

    BucketHandler.list(base_url, api_key, token)
  end

  @doc """
  Retrieves information about a bucket in the current project.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: `select`
    * `objects` permissions: none

  ## Examples

      iex> Supabase.Storage.retrieve_bucket_info(conn, "avatars")
      {:ok, %Supabase.Storage.Bucket{...}}

      iex> Supabase.Storage.retrieve_bucket_info(invalid_conn, "avatars")
      {:error, reason}

  """
  @impl true
  def retrieve_bucket_info(conn, id) do
    base_url = ""
    api_key = ""
    token = ""

    BucketHandler.retrieve_info(base_url, api_key, token, id)
  end

  @doc """
  Creates a new bucket in the current project given a map of attributes.

  ## Attributes

  * `id`: the id of the bucket to be created, required
  * `name`: the name of the bucket to be created, defaults to the `id` provided
  * `file_size_limit`: the maximum size of a file in bytes
  * `allowed_mime_types`: a list of allowed mime types, defaults to allow all MIME types
  * `public`: whether the bucket is public or not, defaults to `false`

  ## Notes

  * Policy permissions required
    * `buckets` permissions: `insert`
    * `objects` permissions: none

  ## Examples

      iex> Supabase.Storage.create_bucket(conn, %{id: "avatars"})
      {:ok, %Supabase.Storage.Bucket{...}}

      iex> Supabase.Storage.create_bucket(invalid_conn, %{id: "avatars"})
      {:error, reason}

  """
  @impl true
  def create_bucket(conn, attrs) do
    with {:ok, bucket_params} <- Bucket.create_changeset(attrs),
         base_url = "",
         api_key = "",
         token = "",
         {:ok, _} <- BucketHandler.create(base_url, api_key, token, bucket_params) do
      retrieve_bucket_info(conn, bucket_params.id)
    end
  end

  @doc """
  Updates a bucket in the current project given a map of attributes.

  ## Attributes

  * `file_size_limit`: the maximum size of a file in bytes
  * `allowed_mime_types`: a list of allowed mime types, defaults to allow all MIME types
  * `public`: whether the bucket is public or not, defaults to `false`

  Isn't possible to update a bucket's `id` or `name`. If you want or need this, you should
  firstly delete the bucket and then create a new one.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: `update`
    * `objects` permissions: none

  ## Examples

      iex> Supabase.Storage.update_bucket(conn, bucket, %{public: true})
      {:ok, %Supabase.Storage.Bucket{...}}

      iex> Supabase.Storage.update_bucket(invalid_conn, bucket, %{public: true})
      {:error, reason}

  """
  @impl true
  def update_bucket(conn, bucket, attrs) do
    with {:ok, bucket_params} <- Bucket.update_changeset(bucket, attrs),
         base_url = "",
         api_key = "",
         token = "",
         {:ok, _} <- BucketHandler.update(base_url, api_key, token, bucket.id, bucket_params) do
      retrieve_bucket_info(conn, bucket.id)
    end
  end

  @doc """
  Empties a bucket in the current project. This action deletes all objects in the bucket.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: `update`
    * `objects` permissions: `delete`

  ## Examples

      iex> Supabase.Storage.empty_bucket(conn, bucket)
      {:ok, :emptied}

      iex> Supabase.Storage.empty_bucket(invalid_conn, bucket)
      {:error, reason}

  """
  @impl true
  def empty_bucket(conn, %Bucket{} = bucket) do
    base_url = ""
    api_key = ""
    token = ""

    BucketHandler.empty(base_url, api_key, token, bucket.id)
  end

  @doc """
  Deletes a bucket in the current project. Notice that this also deletes all objects in the bucket.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: `delete`
    * `objects` permissions: `delete`

  ## Examples

      iex> Supabase.Storage.delete_bucket(conn, bucket)
      {:ok, :deleted}

      iex> Supabase.Storage.delete_bucket(invalid_conn, bucket)
      {:error, reason}

  """
  @impl true
  def delete_bucket(conn, %Bucket{} = bucket) do
    base_url = ""
    api_key = ""
    token = ""

    with {:ok, _} <- BucketHandler.delete(base_url, api_key, token, bucket.id) do
      # remove_current_bucket(conn)
      {:ok, :deleted}
    end
  end

  @doc """
  Removes an object from a bucket in the current project.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `delete`

  ## Examples

      iex> Supabase.Storage.remove_object(conn, bucket, object)
      {:ok, :deleted}

      iex> Supabase.Storage.remove_object(invalid_conn, bucket, object)
      {:error, reason}

  """
  @impl true
  def remove_object(conn, %Bucket{} = bucket, %Object{} = object) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.remove(base_url, api_key, token, bucket.name, object.path)
  end

  @doc """
  Moves a object from a bucket and send it to another bucket, in the current project.
  Notice that isn't necessary to pass the current bucket, because the object already
  contains this information.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `delete` and `create`

  ## Examples

      iex> Supabase.Storage.move_object(conn, bucket, object)
      {:ok, :moved}

      iex> Supabase.Storage.move_object(invalid_conn, bucket, object)
      {:error, reason}

  """
  @impl true
  def move_object(conn, %Bucket{} = bucket, %Object{} = object, to) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.move(base_url, api_key, token, bucket.name, object.path, to)
  end

  @doc """
  Copies a object from a bucket and send it to another bucket, in the current project.
  Notice that isn't necessary to pass the current bucket, because the object already
  contains this information.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `create`

  ## Examples

      iex> Supabase.Storage.copy_object(conn, bucket, object)
      {:ok, :copied}

      iex> Supabase.Storage.copy_object(invalid_conn, bucket, object)
      {:error, reason}

  """
  @impl true
  def copy_object(conn, %Bucket{} = bucket, %Object{} = object, to) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.copy(base_url, api_key, token, bucket.name, object.path, to)
  end

  @doc """
  Retrieves information about an object in a bucket in the current project.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

      iex> Supabase.Storage.retrieve_object_info(conn, bucket, "some.png")
      {:ok, %Supabase.Storage.Object{...}}

      iex> Supabase.Storage.retrieve_object_info(invalid_conn, bucket, "some.png")
      {:error, reason}

  """
  @impl true
  def retrieve_object_info(conn, %Bucket{} = bucket, wildcard) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.get_info(base_url, api_key, token, bucket.name, wildcard)
  end

  @doc """
  Lists a set of objects in a bucket in the current project.

  ## Searching

  You can pass a prefix to filter the objects returned. For example, if you have the following
  objects in your bucket:

      .
      └── bucket/
          ├── avatars/
          │   └── some.png
          ├── other.png
          └── some.pdf

  And you want to list only the objects inside the `avatars` folder, you can do:

      iex> Supabase.Storage.list_objects(conn, bucket, "avatars/")
      {:ok, [%Supabase.Storage.Object{...}]}

  Also you can pass some search options as a `Supabase.Storage.SearchOptions` struct. Available
  options are:

  * `limit`: the maximum number of objects to return
  * `offset`: the number of objects to skip
  * `sort_by`:
    * `column`: the column to sort by, defaults to `created_at`
    * `order`: the order to sort by, defaults to `desc`

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

      iex> Supabase.Storage.list_objects(conn, bucket)
      {:ok, [%Supabase.Storage.Object{...}, ...]}

      iex> Supabase.Storage.list_objects(invalid_conn, bucket)
      {:error, reason}

  """
  @impl true
  def list_objects(conn, %Bucket{} = bucket, prefix \\ "", opts \\ %SearchOptions{}) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.list(base_url, api_key, token, bucket.name, prefix, opts)
  end

  @doc """
  Uploads a file to a bucket in the current project. Notice that you only need to
  pass the path to the file you want to upload, as the file will be read in a stream way
  to be sent to the server.

  ## Options

  You can pass some options as a `Supabase.Storage.ObjectOptions` struct. Available
  options are:

  * `cache_control`: the cache control header value, defaults to `3600`
  * `content_type`: the content type header value, defaults to `text/plain;charset=UTF-8`
  * `upsert`: whether to overwrite the object if it already exists, defaults to `false`

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `insert`

  ## Examples

      iex> Supabase.Storage.upload_object(conn, bucket, "avatars/some.png", "path/to/file.png")
      {:ok, %Supabase.Storage.Object{...}}

      iex> Supabase.Storage.upload_object(invalid_conn, bucket, "avatars/some.png", "path/to/file.png")
      {:error, reason}

  """
  @impl true
  def upload_object(conn, %Bucket{} = bucket, path, file, opts \\ %ObjectOptions{}) do
    base_url = ""
    api_key = ""
    token = ""
    file = Path.expand(file)

    ObjectHandler.create_file(base_url, api_key, token, bucket.name, path, file, opts)
  end

  @doc """
  Downloads an object from a bucket in the current project. That return a binary that
  represents the object content.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

       iex> Supabase.Storage.download_object(conn, %Bucket{}, "avatars/some.png")
       {:ok, <<>>}

       iex> Supabase.Storage.download_object(invalid_conn, %Bucket{}, "avatars/some.png")
       {:error, reason}

  """
  @impl true
  def download_object(conn, %Bucket{} = bucket, wildcard) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.get(base_url, api_key, token, bucket.name, wildcard)
  end

  @doc """
  Downloads an object from a bucket in the current project. That return a stream that
  represents the object content. Notice that the request to the server is only made
  when you start to consume the stream.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

       iex> Supabase.Storage.download_object_lazy(conn, %Bucket{}, "avatars/some.png")
       {:ok, #Function<59.128620087/2 in Stream.resource/3>}

       iex> Supabase.Storage.download_object_lazy(invalid_conn, %Bucket{}, "avatars/some.png")
       {:error, reason}

  """
  @impl true
  def download_object_lazy(conn, %Bucket{} = bucket, wildcard) do
    base_url = ""
    api_key = ""
    token = ""

    ObjectHandler.get_lazy(base_url, api_key, token, bucket.name, wildcard)
  end

  @doc """
  Saves an object from a bucket in the current project to a file in the local filesystem.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

       iex> Supabase.Storage.save_object(conn, "./some.png", %Bucket{}, "avatars/some.png")
       :ok

       iex> Supabase.Storage.save_object(conn, "./some.png", %Bucket{}, "do_not_exist.png")
       {:error, reason}

  """
  @impl true
  def save_object(conn, path, %Bucket{} = bucket, wildcard) do
    with {:ok, bin} <- download_object(conn, bucket, wildcard) do
      File.write(Path.expand(path), bin)
    end
  end

  @doc """
  Saves an object from a bucket in the current project to a file in the local filesystem.
  Notice that the request to the server is only made when you start to consume the stream.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

       iex> Supabase.Storage.save_object_stream(conn, "./some.png", %Bucket{}, "avatars/some.png")
       :ok

       iex> Supabase.Storage.save_object_stream(conn, "./some.png", %Bucket{}, "do_not_exist.png")
       {:error, reason}

  """
  @impl true
  def save_object_stream(conn, path, %Bucket{} = bucket, wildcard) do
    with {:ok, stream} <- download_object_lazy(conn, bucket, wildcard) do
      fs = File.stream!(Path.expand(path))

      stream
      |> Stream.into(fs)
      |> Stream.run()
    end
  end

  @doc """
  Creates a signed URL for an object in a bucket in the current project. This URL can
  be used to perform an HTTP request to the object, without the need of authentication.
  Usually this is used to allow users to download objects from a bucket.

  ## Notes

  * Policy permissions required
    * `buckets` permissions: none
    * `objects` permissions: `select`

  ## Examples

       iex> Supabase.Storage.create_signed_url(conn, bucket, "avatars/some.png", 3600)
       {:ok, "https://<project>.supabase.co"/object/sign/<bucket>/<file>?token=<token>}

       iex> Supabase.Storage.create_signed_url(invalid_conn, bucket, "avatars/some.png", 3600)
       {:error, reason}

  """
  @impl true
  def create_signed_url(conn, %Bucket{} = bucket, path, expires_in) do
    base_url = ""
    api_key = ""
    token = ""

    with {:ok, sign_url} <-
           ObjectHandler.create_signed_url(
             base_url,
             api_key,
             token,
             bucket.name,
             path,
             expires_in
           ) do
      {:ok, URI.to_string(URI.merge(base_url, sign_url))}
    end
  end
end
