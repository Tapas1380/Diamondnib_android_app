@extends('admin.layout.page-app')
@section('page_title', 'Wallet Transaction')

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm">Wallet Transaction</h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-12">
                    <ol class="breadcrumb">
                       <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item"><a href="{{ route('wallet.index') }}">Wallet</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Wallet Transaction</li>
                    </ol>
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr style="background: #F9FAFF;">
                            <th>{{__('Label.#')}}</th>
                            <th>Content Type</th>
                            <th>Audio Book Type</th>
                            <th>Content</th>
                            <th>Episode</th>
                            <th>{{__('Label.Coin')}}</th>
                            <th>Date</th>
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
                    url: "{{ route('wallet.transaction', $id) }}",
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'content_type',
                        name: 'content_type',
                        render: function(data, type, full, meta) {
                            if (data == 1) {
                                return "Audio Book";
                            } else if(data == 2) {
                                return "Novel";
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'audiobook_type',
                        name: 'audiobook_type',
                        render: function(data, type, full, meta) {
                            if (data == 1) {
                                return "Audio";
                            } else if(data == 2) {
                                return "Video";
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'content.title',
                        name: 'content.title',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'episode.name',
                        name: 'episode.name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                    {
                        data: 'coin',
                        name: 'coin',
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
        });
    </script>
@endsection