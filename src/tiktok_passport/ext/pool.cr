require "pool/connection"

class Pool(T)
  def each_resource
    @pool.each do |resource|
      yield(resource)
    end
  end
end
