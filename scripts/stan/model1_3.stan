data {
  int<lower=1> K;                       // number of mixture components
  ordered[K] beta;                      // centers of mixture components
  int<lower=0> N;                       // number of ROIs x observations (subjs x waves)
  int<lower=0> N_roi;                   // number of ROIs
  int<lower=0> N_subj;                  // number of subjects
  real cope[N];                         // estimated effects for each observation of roi
  int<lower=1, upper=N_roi> roi[N];     // ROI ID of each observation
  int<lower=1, upper=N_subj> subj[N];   // subject ID of each observation
  real<lower=0> varcope[N];             // s.e. of effect estimates
}
parameters {
  simplex[K] phi;           // mixing proportions
  real<lower=0> tau_roi;    // SD of hyper-distribution of eta_roi
  real<lower=0> tau_subj;   // SD of hyper-distribution of eta_subj
  matrix[N_roi, K] eta_roi; // centered parameterization of roi-specific effect estimate
  vector[N_subj] eta_subj;  // centered parameterization of roi-specific effect estimate
}
model {
  vector[2] log_phi = log(phi);  // cache log calculation
  
  // rather informative prior for all betas
  beta ~ normal(0, 1);
  
  // weakly informative prior for taus
  tau_roi ~ normal(0, 1);
  tau_subj ~ normal(0, 1);
  
  // weakly informative prior for etas
  for (k in 1:K) {
    eta_roi[, k] ~ normal(0, 1);
  }
  
  eta_subj ~ normal(0, 1);
  
  // likelihood stuff
  for (n in 1:N) {
    vector[K] lps = log_phi;
    for (k in 1:K)
      lps[k] += normal_lpdf(cope[n] | beta[k] + tau_roi * eta_roi[roi[n], k] + tau_subj * eta_subj[subj[n]], varcope[n]);
    target += log_sum_exp(lps);
  }
}
