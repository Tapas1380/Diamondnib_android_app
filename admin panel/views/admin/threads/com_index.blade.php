@extends('admin.layout.page-app')
@section('page_title', 'Threads Comment')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Threads  Comment</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('threads.index') }}">Threads</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Comment</li>
                    </ol>
                </div>
            </div>

            <!-- Search -->
            <div class="page-search mb-3">
                <div class="input-group" title="Search">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="Search Comment" aria-label="Search" aria-describedby="basic-addon1">
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
                            <th>Comment</th>
                            <th> {{__('Label.Date')}} </th>
                            <th> {{__('Label.Action')}} </th>
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

        // Sidebar Scroll Down
        sidebar_down(500);

        $("#input_user").select2();

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
                    url: "{{ route('threads.comment.index', [$threads_id]) }}",
                    data: function(d) {
                        d.input_search = $('#input_search').val();
                        d.input_user = $('#input_user').val();
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
                        data: 'date',
                        name: 'date'
                    },
                    {
                        data: 'action',
                        name: 'action',
                        orderable: false,
                        searchable: false
                    },
                ],
            });

            $('#input_user').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            }); 
        });

        function change_status(id, status) {

            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var url = "{{route('threads.comment.status', '')}}" + "/" + id;
                $.ajax({
                    type: "POST",
                    url: url,
                    headers: {
                        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
                    },
                    data: id,
                    success: function(resp) {
                        $("#dvloader").hide();
                        if (resp.status == 200) {
                            if (resp.Status_Code == 1) {

                                $('#' + id).text('Show');
                                $('#' + id).css({
                                    "background": "#058f00",
                                    "font-weight":"bold",
                                    "color": "white",
                                    "border": "none",
                                    "outline": "none",
                                    "padding": "5px 15px",
                                    "border-radius": "5px",
                                    "cursor": "pointer",
                                });
                            } else {

                                $('#' + id).text('Hide');
                                $('#' + id).css({
                                    "background": "#e3000b",
                                    "color": "white",
                                    "border": "none",
                                    "outline": "none",
                                    "padding": "5px 20px",
                                    "border-radius": "5px",
                                    "cursor": "pointer",
                                });
                            }
                        } else {
                            toastr.error(resp.errors);
                        }
                    },
                    error: function(XMLHttpRequest, textStatus, errorThrown) {
                        $("#dvloader").hide();
                        toastr.error(errorThrown, textStatus);
                    }
                });
            } else {
                toastr.error('You have no right to add, edit, and delete.');
            }
        };
    </script>
@endsection