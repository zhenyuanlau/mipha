defmodule Mipha.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Comeonin.Bcrypt
  alias Mipha.Regexp

  alias Mipha.{
    Repo,
    Regexp,
    Accounts.User,
    Topics.Topic,
    Replies.Reply
  }

  @type t :: %User{}

  schema "users" do
    field :avatar, :string
    field :bio, :string
    field :email, :string
    field :github_handle, :string
    field :is_admin, :boolean, default: false
    field :password_hash, :string
    field :username, :string
    field :website, :string
    field :password, :string, virtual: true
    field :login, :string, virtual: true

    has_many :topics, Topic, on_delete: :delete_all
    has_many :replies, Reply, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    permitted_attrs = ~w(
      username
      email
      avatar
      bio
      website
      github_handle
      is_admin
    )a

    required_attrs = ~w(
      username
      email
    )a

    user
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
  end

  @doc """
  User login changeset.
  """
  def login_changeset(user, attrs) do
    login_attrs = ~w(
      login
      password
    )a

    user
    |> cast(attrs, login_attrs)
    |> validate_required(login_attrs)
  end

  @doc """
  Registration changeset.
  """
  def register_changeset(user, attrs) do
    permitted_attrs = ~w(
      username
      email
      password
      avatar
      is_admin
      bio
      website
      github_handle
    )a

    register_attrs = ~w(
      username
      email
      password
    )a

    user
    |> cast(attrs, permitted_attrs)
    |> validate_required(register_attrs)
    |> validate_length(:username, min: 3, max: 12)
    |> validate_format(:username, Regexp.username)
    |> unique_constraint(:username)
    |> validate_length(:email, min: 1, max: 20)
    |> validate_format(:email, Regexp.email)
    |> unique_constraint(:email)
    |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end
end