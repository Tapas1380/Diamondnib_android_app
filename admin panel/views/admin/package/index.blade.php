@extends('admin.layout.page-app')
@section('page_title', __('Label.Package'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm"> {{__('Label.Package')}} </h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a> </li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('Label.Package')}}</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end" style="margin-top:-14px">
                    <a href="{{ route('package.create') }}" class="btn btn-default mw-120">{{__('Label.Add Package')}}</a>
                </div>
            </div>

            <!-- Search -->
            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1"><i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i></span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="Search Package" aria-label="Search" aria-describedby="basic-addon1">
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr style="background: #F9FAFF;">
                            <th> {{__('Label.#')}} </th>
                            <th> {{__('Label.Image')}} </th>
                            <th> {{__('Label.Name')}} </th>
                            <th> {{__('Label.Price')}} </th>
                            <th> {{__('Label.Coin')}} </th>
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
        let sidebarHeight = $('.sidebar')[0].scrollHeight;
        sidebar_down(sidebarHeight);

        $(document).ready(function() {
            $(function() {
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
                        url: "{{ route('package.index') }}",
                        data: function(d) {
                            d.input_search = $('#input_search').val();
                        },
                    },
                    columns: [{
                            data: 'DT_RowIndex',
                            name: 'DT_RowIndex'
                        },
                        {
                            data: 'image',
                            name: 'image',
                            orderable: false,
                            searchable: false,
                            "render": function(data, type, full, meta) {
                                return "<a href='" + data + "' target='_blank' title='Watch'><img src='" + data + "' class='img-thumbnail' style='height:55px; width:55px'></a>";
                            },
                        },
                        {
                            data: 'name',
                            name: 'name'
                        },
                        {
                            data: 'price',
                            name: 'price',
                        },
                        {
                            data: 'coin',
                            name: 'coin',
                        },
                        {
                            data: 'action',
                            name: 'action',
                            orderable: false,
                            searchable: false
                        },
                    ],
                });

                $('#input_search').keyup(function() {
                    table.draw();
                });
            });
        });
    </script>
@endsection