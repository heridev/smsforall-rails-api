# frozen_string_literal: true

module V1
  class ApplicationController < ActionController::API
    #### Methods for data serialization
    def render_serialized(obj, serializer, opts = {})
      render_json_dump(serialize_data(obj, serializer, opts))
    end

    def render_json_dump(object, status = :ok)
      render json: object,
             status: status
    end

    # When you don't need to render any data but only
    # a generic hash message
    # eg:
    #   json_content = {
    #     token_auth: 'xsdke9393jdkdj'
    #   }
    # render_json_message(json_content)
    def render_json_message(hash_content)
      data = {
        data: hash_content
      }
      render_json_dump(data, :ok)
    end

    # Specially created to render activerecord errors such as
    # render_error_object(user.errors.messages)
    def render_error_object(hash)
      decorated_params = {
        data: {
          errors: hash
        }
      }
      render_json_dump(decorated_params, :unprocessable_entity)
    end

    def render_with_error(msg = 'Ocurrio un error...')
      data = {
        data: {
          error: msg
        }
      }
      render_json_dump(data, :unprocessable_entity)
    end

    def activerecord_not_found(msg = 'Registro no encontrado')
      data = {
        data: {
          error: msg
        }
      }
      render_json_dump(data, 404)
    end

    def render_unauthorized_resource(payload = {})
      data = {
        data: payload
      }
      render_json_dump(data, 401)
    end

    def render_forbidden_resource(msg = 'Ocurrio un error...', action_name = '')
      data = {
        error: msg,
        action_name: action_name
      }
      render_json_dump(data, 403)
    end

    def serialize_data(obj, serializer, options = {})
      serializer.new(obj, options).serializable_hash.to_json
    end
  end
end
