#ifndef PCA_H
#define PCA_H


#include <vector>
#include "Eigen/Dense"
#include "Eigen/Eigenvalues"

using namespace Eigen;
using namespace std;

class PCA
{
public:

    /*
     * Computes the princcipal component of a given matrix. Computation steps:
     * Assert that the input matrix is square matrix.
     * Compute the mean image.
     * Subtract mean image from the data set to get mean centered data vector
     * Compute the covariance matrix from the mean centered data matrix
     * Calculate the eigenvalues and eigenvectors for the covariance matrix
     * Normalize the eigen vectors
     * Find out an eigenvector with the largest eigenvalue
     * 
     * @input MatrixXd D the data samples matrix.
     * 
     * @returns VectorXd The principal component vector
     */
    static VectorXf Compute(MatrixXf D)
    {
        // 1. Compute the mean image
        
        int N = D.cols();


        MatrixXf mean(N, 1);

        for (int i = 0; i < N; i++) {
            mean(i, 0) = D.col(i).mean();
        }
       

        // 2. Subtract mean image from the data set to get mean centered data vector
        MatrixXf U = D;

        for (int i = 0; i < D.rows(); i++)
        {
            for (int j = 0; j < N; j++)
            {
                U(i, j) -= mean(j, 0);
            }
        }

        // 3. Compute the covariance matrix from the mean centered data matrix
        MatrixXf covariance = (U.transpose() * U) / (float)(N);
        //cout << "cov  " << covariance << endl;
        // 4. Calculate the eigenvalues and eigenvectors for the covariance matrix
        EigenSolver<MatrixXf> solver(covariance);
        int mn = (D.rows() == D.cols()) ? 1 : -1;
        MatrixXf w = solver.eigenvectors().real() * mn;
        VectorXf v = solver.eigenvalues().real();
        
         //cout <<"v " << v << endl;
         //cout <<"w "<< w << endl;

        // 6. Find out an eigenvector with the largest eigenvalue
         
        std::vector<std::pair<float, Eigen::VectorXf>> eigen_vectors_and_values;

        for (int i = 0; i < v.size(); i++) {
            std::pair<float, Eigen::VectorXf> vec_and_val(v[i], w.col(i));
            eigen_vectors_and_values.push_back(vec_and_val);
        }
        sort(eigen_vectors_and_values.begin(), eigen_vectors_and_values.end(),
            [&](const std::pair<float, Eigen::VectorXf>& a, const std::pair<float, Eigen::VectorXf>& b) -> bool {
                return a.first > b.first;
            });

        for (int i = 0; i < v.size(); i++) {
            w.col(i) = eigen_vectors_and_values[i].second;
        }
        
        VectorXf featureVector = w.col(0).transpose();
        //cout << "feature vector " << featureVector << endl;
        return U * featureVector;
    }
};

#endif // PCA_H