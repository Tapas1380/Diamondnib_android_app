@extends('artist.layout.page-app')
@section('page_title', 'Threads')

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Threads</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Threads</li>
                    </ol>
                </div>
            </div>

            <!-- Add Threads -->
            <div class="card custom-border-card mt-3">
                <h5 class="card-header">Upload Threads</h5>
                <div class="card-body">
                    <form id="threads" enctype="multipart/form-data">
                        <input type="hidden" name="id" value="">
                        <div class="form-row">
                            <div class="col-md-6">
                                <div class="form-row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label>{{__('Label.Description')}}<span class="text-danger">*</span></label>
                                            <textarea name="description" class="form-control" rows="5" placeholder="Describe Here," autofocus></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group ml-5">
                                    <label class="ml-5">Image<span class="text-danger">*</span></label>
                                    <div class="avatar-upload ml-5">
                                        <div class="avatar-edit">
                                            <input type='file' name="image" id="imageUpload" accept=".png, .jpg, .jpeg" />
                                            <label for="imageUpload" title="Select File"></label>
                                        </div>
                                        <div class="avatar-preview">
                                            <img src="{{asset('assets/imgs/upload_img.png')}}" alt="upload_img.png" id="imagePreview">
                                        </div>
                                    </div>
                                    <label class="mt-3 ml-5 text-gray">Maximum size 2MB.</label>
                                </div>
                            </div>
                        </div>
                        <div class="border-top pt-3 text-right">
                            <button type="button" class="btn btn-default mw-120" onclick="save_threads()">{{__('Label.SAVE')}}</button>
                            <input type="hidden" name="_token" value="{{ csrf_token() }}">
                        </div>
                    </form>
                </div>
            </div>

            <!-- Search -->
            <form action="{{ route('athreads.index')}}" method="GET">
                <div class="page-search mb-3">
                    <div class="input-group">
                        <div class="input-group-prepend">
                            <span class="input-group-text" id="basic-addon1">
                                <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                            </span>
                        </div>
                        <input type="text" name="input_search" value="@if(isset($_GET['input_search'])){{$_GET['input_search']}}@endif" class="form-control" placeholder="Search Threads" aria-label="Search" aria-describedby="basic-addon1">
                    </div>
                    <div class="mr-3 ml-3">
                        <button class="btn btn-default" type="submit">SEARCH</button>
                    </div>
                </div>
            </form>

            <div class="row">
                @foreach ($data as $key => $value)
                <div class="col-12 col-sm-6 col-md-4 col-xl-3">
                    <div class="card video-card">
                        <div class="position-relative">
                            <img class="card-img-top" src="{{$value->image}}" alt="">
                            <ul class="list-inline overlap-control" aria-labelledby="dropdownMenuLink">
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('athreads.comment.index', [$value->id])}}" title="Comment">
                                        <i class="fa-solid fa-comments fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                                <li class="list-inline-item">
                                    <a class="btn" href="{{route('athreads.show', [$value->id])}}" title="Delete" onclick="return confirm('Are you sure !!! You want to Delete this Threads ?')">
                                        <i class="fa-solid fa-trash-can fa-xl" class="dot-icon" style="color: #4e45b8;"></i>
                                    </a>
                                </li>
                            </ul>
                            <button class="btn play-btn-top video" title="Read" data-toggle="modal" data-target="#videoModal" data-description="{{$value->description}}" data-image="{{$value->image}}">
                                <i class="fa-solid fa-book-open-reader text-white fa-3x mr-2 mt-2"></i>  
                            </button>
                        </div>
                        <div class="card-body">
                            <h5 class="card-title">{{$value->description}}</h5>
                            <div class="d-flex justify-content-between card-details">
                                <div class="d-flex text-align-center" title="Total Like">
                                    <span class="d-flex text-align-center mr-3">
                                        <i class="fa-solid fa-thumbs-up fa-xl mr-3" style="color:#4e45b8; margin-top:12px"></i>
                                        <h5 class="counting" data-count="{{no_format($value->total_like ?? 0)}}">{{no_format($value->total_like)}}</h5>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
            </div>

            <!-- Description Model -->
            <div class="modal fade" id="videoModal" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered modal-lg">
                    <div class="modal-content">
                        <div class="modal-body p-0 bg-transparent">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true" class="text-dark">&times;</span>
                            </button>
                            <img src="" alt="" id="image" width="300" height="300" style="padding: 10px;">
                            <p id="description" style="padding: 10px;"></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pagination -->
            <div class="d-flex justify-content-between align-items-center">
                <div> Showing {{ $data->firstItem() }} to {{ $data->lastItem() }} of total {{$data->total()}} entries </div>
                <div class="pb-5"> {{ $data->links() }} </div>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        $("#input_user").select2();
        $("#input_artist").select2();

        $(function() {
            $(".video").click(function() {

                var theModal = $(this).data("target"),
                    description = $(this).attr("data-description"),
                    image = $(this).attr("data-image");

                $("#image").attr("src",image);
                $("#description").text(description);
            });
        });

        function save_threads(){
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#threads")[0]);
                $.ajax({
                    type:'POST',
                    url:'{{ route("athreads.store") }}',
                    data:formData,
                    cache:false,
                    contentType: false,
                    processData: false,
                    success:function(resp){
                        $("#dvloader").hide();
                        get_responce_message(resp, 'threads', '{{ route("athreads.index") }}');
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
		}
    </script>
@endsection