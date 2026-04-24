@extends('admin.layout.page-app')
@section('page_title', __('Label.Transaction'))

@section('content')
    @include('admin.layout.sidebar')

    <div class="right-content">
        @include('admin.layout.header')

        <div class="body-content">
            <!-- mobile title -->
            <h1 class="page-title-sm"> {{__('Label.Transaction')}} </h1>

            <div class="border-bottom row mb-3">
                <div class="col-sm-10">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}">{{__('Label.Dashboard')}}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{__('Label.Transaction')}}</li>
                    </ol>
                </div>
                <div class="col-sm-2 d-flex align-items-center justify-content-end">
                    <a href="{{ route('transaction.create') }}" class="btn btn-default mw-120" style="margin-top:-14px">Add Transaction</a>
                </div>
            </div>

            <!-- Search -->
            <div class="page-search mb-3">
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text" id="basic-addon1">
                            <i class="fa-solid fa-magnifying-glass fa-xl light-gray"></i>
                        </span>
                    </div>
                    <input type="text" id="input_search" class="form-control" placeholder="Search By Payment ID" aria-label="Search" aria-describedby="basic-addon1">
                </div>
                <div class="sorting mr-4" style="width: 40%;">
                    <label>Sort by :</label>
                    <select class="form-control" name="input_package" id="input_package">
                        <option value="0" selected>All Package</option>
                        @for ($i = 0; $i < count($package); $i++) 
                        <option value="{{ $package[$i]['id'] }}" @if(isset($_GET['input_package'])){{ $_GET['input_package'] == $package[$i]['id'] ? 'selected' : ''}} @endif>
                            {{ $package[$i]['name'] }}
                        </option>
                        @endfor
                    </select>
                </div>
                <div class="sorting" style="width: 30%;">
                    <label>Sort by :</label>
                    <select class="form-control" id="input_type">
                        <option value="all">All</option>
                        <option value="today">Today</option>
                        <option value="month">Month</option>
                        <option value="year">Year</option>
                    </select>
                </div>
            </div>

            <div class="table-responsive table">
                <table class="table table-striped text-center table-bordered" id="datatable">
                    <thead>
                        <tr style="background: #F9FAFF;">
                            <th>{{__('Label.#')}}</th>
                            <th>user Name</th>
                            <th>Email</th>
                            <th>Mobile</th>
                            <th>{{__('Label.Package')}}</th>
                            <th>{{__('Label.Price')}}</th>
                            <th>Coin</th>
                            <th>Transaction Id</th>
                            <th>Description</th>
                            <th>{{__('Label.Date')}}</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                    <tfoot>
                        <tr style="background: #F9FAFF;">
                            <td colspan="10" class="text-center"></td>
                        </tr>
                    </tfoot>
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
                    url: "{{ route('transaction.index') }}",
                    data: function(d) {
                        d.input_type = $('#input_type').val();
                        d.input_package = $('#input_package').val();
                        d.input_search = $('#input_search').val();
                    },
                },
                columns: [{
                        data: 'DT_RowIndex',
                        name: 'DT_RowIndex'
                    },
                    {
                        data: 'user.full_name',
                        name: 'user.full_name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'user.email',
                        name: 'user.email',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'user.mobile_number',
                        name: 'user.mobile_number',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'package.name',
                        name: 'package.name',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'price',
                        name: 'price',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
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
                        },
                    },
                    {
                        data: 'transaction_id',
                        name: 'transaction_id',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'description',
                        name: 'description',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        },
                    },
                    {
                        data: 'date',
                        name: 'date',
                        render: function(data, type, full, meta) {
                            if (data) {
                                return data;
                            } else {
                                return "-";
                            }
                        }
                    },
                ],
                footerCallback: function ( row, data, start, end, display ) {
                    var api = this.api(), data;

                    // converting to interger to find total
                    var intVal = function ( i ) {
                        return typeof i === 'string' ? i.replace(/[\$,]/g, '')*1 : typeof i === 'number' ? i : 0;
                    };

                    // computing column Total of the complete result 
                    var Total = api
                        .column(5)
                        .data()
                        .reduce( function (a, b) {
                            return intVal(a) + intVal(b);
                        }, 0 );

                    // Update footer by showing the total with the reference of the column index 
                    $(api.column(1).footer() ).html("Total Amount =&nbsp &nbsp {{currency_code() }}"+ " " + Total);
                },
            });

            $('#input_type, #input_package').change(function() {
                table.draw();
            });
            $('#input_search').keyup(function() {
                table.draw();
            });
        });
    </script>
@endsection