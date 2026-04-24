@extends('admin.layout.page-app')
@section('page_title','Add Transaction')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">@yield('title')</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('transaction.index') }}">Transaction</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Add Transaction</li>
                    </ol>
                </div>
            </div>

            <div class="card custom-border-card mt-3">
                <form enctype="multipart/form-data" id="search_user">
                    @csrf
                    <div class="form-row">
                        <div class="col-8">
                            <div class="form-group">
                                <input name="name" type="text" class="form-control" id="name" placeholder="Search User Name or Mobile" autocomplete="off">
                            </div>
                        </div>
                        <div class="col-4">
                            <button type="button" class="btn btn-default mw-120 mr-3" onclick="search_user()">Search</button>
                            <a href="{{route('transaction.create')}}" class="btn btn-cancel mw-120">Clear</a>
                        </div>
                    </div>
                </form>
            </div>

            <?php if (isset($user->id)) { ?>
                <div class="card custom-border-card mt-3">
                    <form enctype="multipart/form-data" id="add_transaction">
                        @csrf
                        <div class="form-row">
                            <div class="col-4">
                                <div class="form-group">
                                    <input name="user_id" type="hidden" class="form-control" readonly id="user_id" value="{{$user->id}}">
                                    <label> Full Name</label>
                                    <input name="full_name" type="text" class="form-control" readonly value="{{$user->full_name}}">
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="form-group">
                                    <label> Mobile Number</label>
                                    <input name="mobile_number" type="text" class="form-control" readonly value="{{$user->mobile_number}}">
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="form-group">
                                    <label> Email</label>
                                    <input name="email" type="text" class="form-control" readonly value="{{$user->email}}">
                                </div>
                            </div>
                            <div class="col-4">
                                <div class="form-group">
                                    <label> Select Pakage</label>
                                    <select name="package_id" class="form-control">
                                        <option value="">Select Package</option>
                                        @foreach($package as $row)
                                        <option value="{{$row->id}}">{{$row->name}} &nbsp; - &nbsp; {{$row->price}}</option>
                                        @endforeach
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="col-4">
                            <button type="button" class="btn btn-default mw-120" onclick="add_transaction()">Save</button>
                        </div>
                    </form>
                </div>
            <?php } else { ?>
                <div class="card custom-border-card mt-3">
                    <div class="col-12">
                        <h3>User List</h3>

                        <div id="user_list"></div>
                    </div>
                </div>
            <?php } ?>
        </div>
    </div>
@endsection

@section('pagescript')
    <script>

        // Sidebar Scroll Down
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

        function add_transaction() {
            var Check_Admin = '<?php echo Check_Admin_Access(); ?>';
            if(Check_Admin == 1){

                $("#dvloader").show();
                var formData = new FormData($("#add_transaction")[0]);
                $.ajax({
                    type: 'POST',
                    url: '{{ route("transaction.store") }}',
                    data: formData,
                    cache: false,
                    contentType: false,
                    processData: false,
                    success: function(resp) {
                        $("#dvloader").hide();
                        get_responce_message(resp, 'add_transaction', '{{ route("transaction.index") }}');
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

        function search_user() {
            var formData = new FormData($("#search_user")[0]);
            $("#dvloader").show();
            $.ajax({
                type: 'POST',
                url: '{{ route("searchUser")}}',
                data: formData,
                cache: false,
                contentType: false,
                processData: false,
                success: function(resp) {
                    $("#dvloader").hide();
                    $('#user_list').html(resp.result);
                },
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    $("#dvloader").hide();
                    toastr.error(errorThrown, textStatus);
                }
            });
        }
    </script>
@endsection