context("Downloading functions")

test_that("Sites", {
  
  expect_equal(nrow(get_wacl_sites()), 2)
  
})

test_that("Processes", {
  
  data_processes <- get_wacl_processes()
  expect_equal(class(data_processes), "data.frame")

})

test_that("Observations, hourly", {
  
  data_fracking <- get_wacl_data(c("kirb", "litp"), year = 2016, period = "hour")
  expect_equal(class(data_fracking), "data.frame")
  
})

test_that("Observations, source", {
  
  data_fracking <- get_wacl_data(c("kirb", "litp"), year = 2016, period = "source")
  expect_equal(class(data_fracking), "data.frame")
  
})