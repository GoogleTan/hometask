function swap!(arr, i, j)
    temp = arr[i]
    arr[i] = arr[j]
    arr[j] = temp
end

function iota(l)
    res = zeros(Int, l)
    for i in range(1, l)
        res[i] = i
    end
    return res
end

function bubleperm(arr)
    res = iota(length(arr))
    for i in range(1, length(arr))
        for j in range(i + 1, length(arr)) 
            if arr[res[i]] > arr[res[j]]
				swap!(res, i, j)
            end
        end
    end
    return res
end


function insertperm(arr)
    res = iota(length(arr))
    for j in range(2, length(arr))
        key = arr[j]
        i = j-1
        while i >= 1 && arr[i] > key 
            arr[i + 1] = arr[i]
            i = i - 1
        end
        arr[i+1] = key
    end
    return res
end

function seftperm(arr, factor = 1.25) 
    res = iota(length(arr))
	step = length(arr) - 1
    
	while (step >= 1)
        i = 1
		while i + step <= length(arr)
			if arr[res[i]] > arr[res[i + step]]
				swap!(res, i, i + step)
			end
            i += 1
	    end
		step /= factor;
        step = Int(floor(step))
    end
    return res
end

function shellperm(arr)
    res = iota(length(arr))
    s = Int(floor(length(arr) // 2))
    while s > 0
        i = s
        while i < length(arr) 
            j = i - s
            while j >= 0 && arr[res[j + 1]] > arr[res[j + s + 1]]
                swap!(res, j + 1, j+s + 1);
                j -= s
            end
            i += 1
        end
        s //= 2
        s = Int(floor(s))
    end
    return res
end

divv(a, b) = Int(floor(a / b))

function waveperm(arr)
    function unite(a, b)
       if length(a) == 0
            return b
       elseif length(b) == 0
            return a
       elseif arr[a[begin]] < arr[b[begin]]
            return hcat([a[begin]], unite(a[2:end], b))
       else
            return hcat([b[begin]], unite(a, b[2:end]))
       end
    end

    function wave(res)
        if length(res) <= 1
            return res
        end
        return unite( 
                wave(res[begin:divv(length(res), 2)]), 
                wave(res[divv(length(res), 2)+1:end])
            )
    end
    return wave(iota(length(arr)))
end

function hoarperm(arr)
    res = iota(length(arr))

    function partition(low, high)
        mid := (low + high) / 2
        if A[mid] < A[low]
            swap A[low] with  A[mid]
        if A[high] < A[low]
            swap A[low] with A[high]
        if A[high] < A[mid]
            swap A[high] with A[mid]
        pivot:= A[mid]
    end

    function qsort(low, high)
        if low < high
            p = partition(low, high)
            qsort(low, p - 1)
            qsort(p, high)
        end
    end
    qsort(1, length(res))
    return res
end

function my_sort(arr :: AbstractVector{T}, perm_fnc = bubleperm) where T 
    perm = perm_fnc(arr)
    res = zeros(T, length(arr))
    for i in range(1, length(perm)) 
        res[i] = arr[perm[i]]
    end
    return res
end