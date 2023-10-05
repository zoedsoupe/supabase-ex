# Supabase Storage

This module provides a set of Elixir functions that integrate seamlessly with Supabase's Storage API, allowing developers to perform various operations on buckets and objects.

### Features

1. **Bucket Operations**: Easily create, list, empty, or remove buckets.
2. **Object Operations**:
   - Upload & Download objects.
   - Retrieve object information.
   - Move, copy, or remove objects.
   - Generate signed URLs for authenticated access.
   - Stream download operations for efficient memory usage.

### Usage

Here are some examples of how you can use this package:

#### Removing an object

```elixir
Supabase.Storage.remove_object(conn, bucket, object)
```

#### Moving an object

```elixir
Supabase.Storage.move_object(conn, bucket, object, destination)
```

#### Copying an object

```elixir
Supabase.Storage.copy_object(conn, bucket, object, destination)
```

#### Uploading a file

```elixir
Supabase.Storage.upload_object(conn, bucket, "avatars/some.png", "path/to/file.png")
```

#### Creating a signed URL

```elixir
Supabase.Storage.create_signed_url(conn, bucket, "avatars/some.png", 3600)
```

### Permissions

Ensure that the appropriate policy permissions are set in Supabase to carry out the required operations. Refer to each method's documentation for detailed information on permissions.
