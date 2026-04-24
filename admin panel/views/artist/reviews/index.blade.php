@extends('artist.layout.page-app')
@section('page_title', 'Reviews')

@section('content')
    @include('artist.layout.sidebar')

    <div class="right-content">
        @include('artist.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Reviews</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('artist.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Reviews</li>
                    </ol>
                </div>
            </div>

            <!-- Search -->
            <div class="page-search mb-3">
                <div class="input-group" title="Search">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="Search Reviews" aria-label="Search" aria-describedby="basic-addon1">
                </div>
                <div class="sorting mr-2" style="width: 90%;">
                    <label>Sort by :</label>
                    <select class="form-control" name="input_content" id="input_content">
                        <option value="0" selected>All Content</option>
                        @for ($i = 0; $i < count($content); $i++)
                            <option value="{{ $content[$i]['id'] }}" @if(isset($_GET['input_content'])){{ $_GET['input_content'] == $content[$i]['id'] ? 'selected' : ''}} @endif>
                                {{ $content[$i]['title'] }}
                            </option>
                        @endfor
                    </select>
                </div>
                <div class="sorting mr-2" style="width: 50%;">
                    <label>Sort by :</label>
                    <select class="form-control" name="input_user" id="input_user">
                        <option value="0" selected>All User</option>
                        @for ($i = 0; $i < count($user); $i++) 
                            <option value="{{ $user[$i]['id'] }}" @if(isset($_GET['input_user'])){{ $_GET['input_user'] == $user[$i]['id'] ? 'selected' : ''}} @endif>
                                {{ $user[$i]['full_name'] }}
                            </option>
                        @endfor
                    </select>
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr style="background: #F9FAFF;">
                            <th>{{__('Label.#')}}</th>
                            <th>User</th>
                            <th>Content Type</th>
                            <th>Content</th>
                            <th>Comment</th>
                            <th>Rating (Out Of 5)</th>
                            <th>{{__('Label.Date')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>
        $("#input_user").select2();
        $("#input_content").select2();

        $(document).ready(function() {
            var table = $('#datatable').DataTable({
                dom: "<'top'f>rt<'row'<'col-2'i><'col-1'l><'col-9'p>>",
                searching: false,
                responsive: true,
                autoWidth: false,
                processing: true,
                serverSide: true,
                lengthMenu: [
                    [10, 100, 500, -1],
                    [10, 100, 500, "All"]
                ],
                language: {
                    paginate: {
                        previous: "<i class='fa-solid fa-chevron-left'></i>",
                        next: "<i class='fa-solid fa-chevron-right'></i>"
                    }
                },
                ajax: {
                    url: "{{ route('areviews.index') }}",
                    data: function(d) {
                        d.input_search = $('#input_search').val();
                        d.input_user = $('#input_user').val();
                        d.input_content = $('#input_content').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'user.full_name',
                        name: 'user.full_name',
                        orderable: false,
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'content_type',
                        name: 'content_type',
                        orderable: false,
                        render: function(data, type, full, meta) {
                            if (data == 1) {
                                return 'Audio Book';
                            } else if(data == 2) {
                                return 'Novel';
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'content.title',
                        name: 'content.title',
                        orderable: false,
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'comment',
                        name: 'comment',
                        orderable: false,
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'rating',
                        name: 'rating',
                        orderable: false,
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "0";
                            }
                        }
                    },
                    {
                        data: 'date',
                        name: 'date'
                    },
                ],
            });

            $('#input_user, #input_content').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            });
        });
    </script>
@endsection