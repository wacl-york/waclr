context("Downloading functions")

test_that("Sites", {
  
  expect_equal(nrow(get_wacl_sites()), 3)
  
})

test_that("Processes", {
  
  data_processes <- get_wacl_processes()
  expect_equal(class(data_processes), "data.frame")

})

test_that("Observations, hourly", {
  
  data_wacl <- get_wacl_data(c("kirb", "litp", "btt"), year = 2016, period = "hour")
  expect_equal(class(data_wacl), "data.frame")
  expect_equal(length(unique(data_wacl$site)), 3)
  
})

test_that("Observations, source", {
  
  # Just one site for speed
  data_btt <- get_wacl_data("btt", year = 2016, period = "source")
  expect_equal(class(data_btt), "data.frame")
  expect_equal(length(unique(data_btt$site)), 1)

})

test_that("Invalidations", {
  
  data_invalidations <- get_wacl_invalidations()
  expect_equal(class(data_invalidations), "data.frame")
  
})
